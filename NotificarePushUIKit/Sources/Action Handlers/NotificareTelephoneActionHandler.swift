//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareTelephoneActionHandler: NotificareBaseActionHandler {
    internal override func execute() {
        if
            let target = action.target,
            let url = URL(string: target),
            UIApplication.shared.canOpenURL(url)
        {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.async {
                        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
                    }

                    Task {
                        try? await Notificare.shared.createNotificationReply(notification: self.notification, action: self.action)
                    }

                    self.dismiss()
                }
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }
        }
    }

    private func dismiss() {
        if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }
}

extension NotificareTelephoneActionHandler {
    public enum ActionError: LocalizedError {
        case notSupported

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support this action."
            }
        }
    }
}
