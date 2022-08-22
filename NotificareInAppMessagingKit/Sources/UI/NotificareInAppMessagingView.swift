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

        NotificareLogger.debug("Tracking in-app message viewed event.")
        Notificare.shared.events().logInAppMessageViewed(message) { result in
            if case let .failure(error) = result {
                NotificareLogger.error("Failed to log in-message viewed event.", error: error)
            }
        }
    }

    func dismiss() {
        // TODO: animate away before removing.
        removeFromSuperview()

        delegate?.onViewDismissed()
    }

    func handleActionClicked(_ actionType: NotificareInAppMessage.ActionType) {
        Notificare.shared.events().logInAppMessageActionClicked(message) { result in
            if case let .failure(error) = result {
                NotificareLogger.error("Failed to log in-app message action.", error: error)
            }

            let action: NotificareInAppMessage.Action?

            switch actionType {
            case .primary:
                action = self.message.primaryAction

            case .secondary:
                action = self.message.secondaryAction
            }

            if let action = action, let urlStr = action.url, let url = URL(string: urlStr) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { success in
                        if success {
                            NotificareLogger.info("In-app message action '${actionType.rawValue}' successfully processed.")

//                            onMainThread {
//                                Notificare.inAppMessagingImplementation().lifecycleListeners.forEach {
//                                    it.onActionExecuted(message, action)
//                                }
//                            }
                        } else {
                            NotificareLogger.warning("Unable to open the action's URL.")

//                            onMainThread {
//                                Notificare.inAppMessagingImplementation().lifecycleListeners.forEach {
//                                    it.onActionFailedToExecute(message, action, e)
//                                }
//                            }
                        }
                    }
                } else {
                    NotificareLogger.warning("Unable to open the action's URL.")

//                    onMainThread {
//                        Notificare.inAppMessagingImplementation().lifecycleListeners.forEach {
//                            it.onActionFailedToExecute(message, action, e)
//                        }
//                    }
                }
            }

            self.dismiss()
        }
    }
}

public protocol NotificareInAppMessagingViewDelegate: AnyObject {
    func onViewDismissed()
}
