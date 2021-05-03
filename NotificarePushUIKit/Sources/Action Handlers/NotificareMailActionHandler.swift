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
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.notSupported)
            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(recipients)
        composer.setSubject(NotificareLocalizable.string(resource: .actionMailSubject))
        composer.setMessageBody(NotificareLocalizable.string(resource: .actionMailBody), isHTML: false)

        NotificarePushUI.shared.presentController(composer, in: sourceViewController)
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
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            Notificare.shared.createNotificationReply(notification: notification, action: action) { _ in }

        case .cancelled:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didNotExecuteAction: action, for: notification)

        case .failed:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: error)

        default:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: error)
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
