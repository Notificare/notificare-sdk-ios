//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

internal class NotificareInAppMessagingImpl: NSObject, NotificareModule, NotificareInAppMessaging {
    private var presentedView: NotificareInAppMessagingView?
    private var presentedViewBackgroundTimestamp: Date?
    private var messageWorkItem: DispatchWorkItem?

    // MARK: - Notificare Module

    internal static let instance = NotificareInAppMessagingImpl()

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false

        // Listen to when the application comes into the foreground.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // Listen to when the application goes into the background.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    internal func launch() async throws {
        evaluateContext(.launch)
    }

    // MARK: - Notificare In-App Messaging

    public weak var delegate: NotificareInAppMessagingDelegate?

    public var hasMessagesSuppressed: Bool = false

    public func setMessagesSuppressed(_ suppressed: Bool, evaluateContext: Bool) {
        if hasMessagesSuppressed == suppressed { return }

        hasMessagesSuppressed = suppressed

        if suppressed {
            if messageWorkItem != nil {
                logger.info("Clearing delayed in-app message from being presented when suppressed.")

                messageWorkItem?.cancel()
                messageWorkItem = nil
            }

            return
        }

        if evaluateContext {
            self.evaluateContext(.foreground)
        }
    }

    // MARK: - Private API

    private func evaluateContext(_ context: ApplicationContext) {
        logger.debug("Checking in-app message for context '\(context.rawValue)'.")

        Task {
            do {
                let message = try await fetchInAppMessage(for: context)

                await processInAppMessage(message)
            } catch {
                if case let NotificareNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                    logger.debug("There is no in-app message for '\(context.rawValue)' context to process.")

                    if context == .launch {
                        self.evaluateContext(.foreground)
                    }

                    return
                }

                logger.error("Failed to process in-app message for context '\(context.rawValue)'.", error: error)
            }
        }
    }

    @MainActor
    private func processInAppMessage(_ message: NotificareInAppMessage) {
        logger.info("Processing in-app message '\(message.name)'.")

        if message.delaySeconds > 0 {
            logger.debug("Waiting \(message.delaySeconds) seconds before presenting the in-app message.")

            let workItem = DispatchWorkItem {
                self.present(message)
                self.messageWorkItem = nil
            }

            // Keep a reference to the work item to cancel it when
            // the app goes into the background.
            messageWorkItem = workItem

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(message.delaySeconds), execute: workItem)
            return
        }

        present(message)
    }

    @MainActor
    private func present(_ message: NotificareInAppMessage) {
        Task {
            let cache = NotificareImageCache()

            do {
                try await cache.preloadImages(for: message)
            } catch {
                logger.error("Failed to preload the in-app message images.", error: error)

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didFailToPresentMessage: message)
                }

                return
            }

            present(message, cache: cache)
        }
    }

    @MainActor
    private func present(_ message: NotificareInAppMessage, cache: NotificareImageCache) {
        guard presentedView == nil else {
            logger.warning("Cannot display an in-app message while another is being presented.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard !hasMessagesSuppressed else {
            logger.debug("Cannot display an in-app message while messages are being suppressed.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let parentView = findParentView() else {
            logger.warning("Cannot display an in-app message without a reference to the parent view.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let view = self.createMessageView(for: message, cache: cache) else {
            logger.warning("Cannot display an in-app message without a view implementation for the given type.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        view.delegate = self
        view.present(in: parentView)

        self.presentedView = view
    }

    private func fetchInAppMessage(for context: ApplicationContext) async throws -> NotificareInAppMessage {
        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let response = try await NotificareRequest.Builder()
            .get("/inappmessage/forcontext/\(context.rawValue)")
            .query(name: "deviceID", value: device.id)
            .responseDecodable(NotificareInternals.PushAPI.Responses.InAppMessage.self)

        return response.message.toModel()
    }

    @MainActor
    private func findParentView() -> UIView? {
        let window: UIWindow

        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
                logger.debug("Unable to acquire the first UIWindowScene.")
                return nil
            }

            if #available(iOS 15.0, *) {
                guard let keyWindow = scene.keyWindow else {
                    logger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            } else {
                guard let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) else {
                    logger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            }
        } else {
            guard let keyWindow = UIApplication.shared.delegate?.window ?? nil else {
                logger.debug("Unable to acquire the key window.")
                return nil
            }

            window = keyWindow
        }

        guard let rootViewController = window.rootViewController else {
            logger.debug("Unable to acquire the root view controller.")
            return nil
        }

        return rootViewController.view
    }

    private func createMessageView(for message: NotificareInAppMessage, cache: NotificareImageCache) -> NotificareInAppMessagingView? {
        let type = NotificareInAppMessage.MessageType(rawValue: message.type)

        switch type {
        case .banner:
            return NotificareInAppMessagingBannerView(message: message, cache: cache)

        case .card:
            return NotificareInAppMessagingCardView(message: message, cache: cache)

        case .fullscreen:
            return NotificareInAppMessagingFullscreenView(message: message, cache: cache)

        default:
            logger.warning("Unsupported in-app message type '\(message.type)'.")
            return nil
        }
    }

    @objc private func onApplicationForeground() {
        if let presentedView = presentedView, let presentedViewBackgroundTimestamp = presentedViewBackgroundTimestamp {
            let now = Date().timeIntervalSince1970 * 1000
            let backgroundGracePeriod = Double(Notificare.shared.options?.backgroundGracePeriodMillis ?? NotificareOptions.DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS)
            let expiredAt = presentedViewBackgroundTimestamp.timeIntervalSince1970 * 1000 + backgroundGracePeriod

            if now > expiredAt {
                logger.debug("Dismissing the current in-app message for being in the background for longer than the grace period.")
                presentedView.removeFromSuperview()

                self.presentedView = nil
                self.presentedViewBackgroundTimestamp = nil
            }
        }

        guard Notificare.shared.isReady else {
            logger.debug("Postponing in-app message evaluation until Notificare is launched.")
            return
        }

        guard presentedView == nil else {
            logger.debug("Skipping context evaluation since there is another in-app message being presented.")
            return
        }

        guard !hasMessagesSuppressed else {
            logger.debug("Skipping context evaluation since in-app messages are being suppressed.")
            return
        }

        evaluateContext(.foreground)
    }

    @objc private func onApplicationBackground() {
        presentedViewBackgroundTimestamp = Date()

        if messageWorkItem != nil {
            logger.info("Clearing delayed in-app message from being presented when going to the background.")
            messageWorkItem?.cancel()
            messageWorkItem = nil
        }
    }
}

extension NotificareInAppMessagingImpl: NotificareInAppMessagingViewDelegate {
    internal func onViewDismissed() {
        presentedView = nil
    }
}
