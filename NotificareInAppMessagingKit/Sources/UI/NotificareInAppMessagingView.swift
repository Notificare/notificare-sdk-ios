//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public protocol NotificareInAppMessagingView: UIView {
    // MARK: - Properties

    var message: NotificareInAppMessage { get }

    var delegate: NotificareInAppMessagingViewDelegate? { get set }

    // MARK: - Methods

    func present(in parentView: UIView)

    func animate(transition: NotificareInAppMessagingViewTransition)

    func animate(transition: NotificareInAppMessagingViewTransition, _ completion: @escaping () -> Void)

    func dismiss()

    func handleActionClicked(_ actionType: NotificareInAppMessage.ActionType)
}

public extension NotificareInAppMessagingView {
    func present(in parentView: UIView) {
        parentView.addSubview(self)
        parentView.bringSubviewToFront(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])

        parentView.layoutIfNeeded()
        animate(transition: .enter)

        DispatchQueue.main.async {
            Notificare.shared.inAppMessaging().delegate?.notificare(Notificare.shared.inAppMessaging(), didPresentMessage: self.message)
        }

        NotificareLogger.debug("Tracking in-app message viewed event.")
        Notificare.shared.events().logInAppMessageViewed(message) { result in
            if case let .failure(error) = result {
                NotificareLogger.error("Failed to log in-message viewed event.", error: error)
            }
        }
    }

    func animate(transition: NotificareInAppMessagingViewTransition) {
        animate(transition: transition) {}
    }

    func dismiss() {
        animate(transition: .exit) {
            self.removeFromSuperview()
            self.delegate?.onViewDismissed()

            DispatchQueue.main.async {
                Notificare.shared.inAppMessaging().delegate?.notificare(Notificare.shared.inAppMessaging(), didFinishPresentingMessage: self.message)
            }
        }
    }

    func handleActionClicked(_ actionType: NotificareInAppMessage.ActionType) {
        let action: NotificareInAppMessage.Action?

        switch actionType {
        case .primary:
            action = message.primaryAction

        case .secondary:
            action = message.secondaryAction
        }

        guard let action = action else {
            NotificareLogger.debug("There is no '\(actionType.rawValue)' action to process.")
            dismiss()

            return
        }

        guard let urlStr = action.url, let url = URL(string: urlStr) else {
            NotificareLogger.debug("There is no URL for '\(actionType.rawValue)' action.")
            dismiss()

            return
        }

        Notificare.shared.events().logInAppMessageActionClicked(message, action: actionType) { result in
            if case let .failure(error) = result {
                NotificareLogger.error("Failed to log in-app message action.", error: error)
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        NotificareLogger.info("In-app message action '\(actionType.rawValue)' successfully processed.")

                        DispatchQueue.main.async {
                            Notificare.shared.inAppMessaging().delegate?.notificare(Notificare.shared.inAppMessaging(), didExecuteAction: action, for: self.message)
                        }
                    } else {
                        NotificareLogger.warning("Unable to open the action's URL.")

                        DispatchQueue.main.async {
                            Notificare.shared.inAppMessaging().delegate?.notificare(Notificare.shared.inAppMessaging(), didFailToExecuteAction: action, for: self.message, error: nil)
                        }
                    }
                }
            } else {
                NotificareLogger.warning("Unable to open the action's URL.")

                DispatchQueue.main.async {
                    Notificare.shared.inAppMessaging().delegate?.notificare(Notificare.shared.inAppMessaging(), didFailToExecuteAction: action, for: self.message, error: nil)
                }
            }

            self.dismiss()
        }
    }
}

public protocol NotificareInAppMessagingViewDelegate: AnyObject {
    func onViewDismissed()
}

public enum NotificareInAppMessagingViewTransition {
    case enter
    case exit
}
