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

    static let instance = NotificareInAppMessagingImpl()

    func configure() {
        // Listen to when the application comes into the foreground.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationForeground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to when the application goes into the background.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        evaluateContext(.launch)

        completion(.success(()))
    }

    // MARK: - Notificare In-App Messaging

    weak var delegate: NotificareInAppMessagingDelegate?

    var hasMessagesSuppressed: Bool = false

    func setMessagesSuppressed(_ suppressed: Bool, evaluateContext: Bool) {
        let suppressChanged = suppressed != hasMessagesSuppressed
        let canEvaluate = evaluateContext && suppressChanged && !suppressed

        hasMessagesSuppressed = suppressed

        if canEvaluate {
            self.evaluateContext(.foreground)
        }
    }

    // MARK: - Private API

    private func evaluateContext(_ context: ApplicationContext) {
        NotificareLogger.debug("Checking in-app message for context '\(context.rawValue)'.")

        fetchInAppMessage(for: context) { result in
            switch result {
            case let .success(message):
                self.processInAppMessage(message)

            case let .failure(error):
                if case let NotificareNetworkError.validationError(response, _, _) = error, response.statusCode == 404 {
                    NotificareLogger.debug("There is no in-app message for '\(context.rawValue)' context to process.")

                    if context == .launch {
                        self.evaluateContext(.foreground)
                    }

                    return
                }

                NotificareLogger.error("Failed to process in-app message for context '\(context.rawValue)'.", error: error)
            }
        }
    }

    private func processInAppMessage(_ message: NotificareInAppMessage) {
        NotificareLogger.info("Processing in-app message '\(message.name)'.")

        if message.delaySeconds > 0 {
            NotificareLogger.debug("Waiting \(message.delaySeconds) seconds before presenting the in-app message.")

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

    private func present(_ message: NotificareInAppMessage) {
        guard presentedView == nil else {
            NotificareLogger.warning("Cannot display an in-app message while another is being presented.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard !hasMessagesSuppressed else {
            NotificareLogger.debug("Cannot display an in-app message while messages are being suppressed.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let parentView = findParentView() else {
            NotificareLogger.warning("Cannot display an in-app message without a reference to the parent view.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        guard let view = createMessageView(for: message) else {
            NotificareLogger.warning("Cannot display an in-app message without a view implementation for the given type.")

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didFailToPresentMessage: message)
            }

            return
        }

        view.delegate = self
        view.present(in: parentView)

        presentedView = view
    }

    private func fetchInAppMessage(for context: ApplicationContext, _ completion: @escaping NotificareCallback<NotificareInAppMessage>) {
        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .get("/inappmessage/forcontext/\(context.rawValue)")
            .query(name: "deviceID", value: device.id)
            .responseDecodable(NotificareInternals.PushAPI.Responses.InAppMessage.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.message.toModel()))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    private func findParentView() -> UIView? {
        let window: UIWindow

        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
                NotificareLogger.debug("Unable to acquire the first UIWindowScene.")
                return nil
            }

            if #available(iOS 15.0, *) {
                guard let keyWindow = scene.keyWindow else {
                    NotificareLogger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            } else {
                guard let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) else {
                    NotificareLogger.debug("Unable to acquire the key window.")
                    return nil
                }

                window = keyWindow
            }
        } else {
            guard let keyWindow = UIApplication.shared.delegate?.window ?? nil else {
                NotificareLogger.debug("Unable to acquire the key window.")
                return nil
            }

            window = keyWindow
        }

        guard let rootViewController = window.rootViewController else {
            NotificareLogger.debug("Unable to acquire the root view controller.")
            return nil
        }

        return rootViewController.view
    }

    private func createMessageView(for message: NotificareInAppMessage) -> NotificareInAppMessagingView? {
        let type = NotificareInAppMessage.MessageType(rawValue: message.type)

        switch type {
        case .banner:
            return NotificareInAppMessagingBannerView(message: message)

        case .card:
            return NotificareInAppMessagingCardView(message: message)

        case .fullscreen:
            return NotificareInAppMessagingFullscreenView(message: message)

        default:
            NotificareLogger.warning("Unsupported in-app message type '\(message.type)'.")
            return nil
        }
    }

    @objc private func onApplicationForeground() {
        if let presentedView = presentedView, let presentedViewBackgroundTimestamp = presentedViewBackgroundTimestamp {
            let now = Date().timeIntervalSince1970 * 1000
            let backgroundGracePeriod = Double(Notificare.shared.options?.backgroundGracePeriodMillis ?? NotificareOptions.DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS)
            let expiredAt = presentedViewBackgroundTimestamp.timeIntervalSince1970 * 1000 + backgroundGracePeriod

            if now > expiredAt {
                NotificareLogger.debug("Dismissing the current in-app message for being in the background for longer than the grace period.")
                presentedView.removeFromSuperview()

                self.presentedView = nil
                self.presentedViewBackgroundTimestamp = nil
            }
        }

        guard Notificare.shared.isReady else {
            NotificareLogger.debug("Postponing in-app message evaluation until Notificare is launched.")
            return
        }

        guard presentedView == nil else {
            NotificareLogger.debug("Skipping context evaluation since there is another in-app message being presented.")
            return
        }

        guard !hasMessagesSuppressed else {
            NotificareLogger.debug("Skipping context evaluation since in-app messages are being suppressed.")
            return
        }

        evaluateContext(.foreground)
    }

    @objc private func onApplicationBackground() {
        presentedViewBackgroundTimestamp = Date()

        if messageWorkItem != nil {
            NotificareLogger.info("Clearing delayed in-app message from being presented when going to the background.")
            messageWorkItem?.cancel()
            messageWorkItem = nil
        }
    }
}

extension NotificareInAppMessagingImpl: NotificareInAppMessagingViewDelegate {
    func onViewDismissed() {
        presentedView = nil
    }
}
