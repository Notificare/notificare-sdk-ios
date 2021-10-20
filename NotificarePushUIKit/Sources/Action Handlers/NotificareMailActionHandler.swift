//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareKit

public class NotificareMailActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        guard let target = action.target, MFMailComposeViewController.canSendMail() else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: ActionError.notSupported)
            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(recipients)
        composer.setSubject(NotificareLocalizable.string(resource: .actionMailSubject))
        composer.setMessageBody(NotificareLocalizable.string(resource: .actionMailBody), isHTML: false)

        sourceViewController.presentOrPush(composer)
    }

    private func dismiss() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }
}

extension NotificareMailActionHandler: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .saved, .sent:
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: action, for: notification)
            Notificare.shared.createNotificationReply(notification: notification, action: action) { _ in }

        case .cancelled:
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didNotExecuteAction: action, for: notification)

        case .failed:
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: error)

        default:
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: error)
        }

        dismiss()
    }
}

public extension NotificareMailActionHandler {
    enum ActionError: LocalizedError {
        case notSupported

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support sending an email."
            }
        }
    }
}
