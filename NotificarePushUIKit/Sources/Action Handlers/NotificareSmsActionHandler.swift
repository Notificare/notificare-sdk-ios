//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareCore
import NotificareKit

public class NotificareSmsActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        guard let target = action.target, MFMessageComposeViewController.canSendText() else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.notSupported)
            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = recipients
        composer.body = ""

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

extension NotificareSmsActionHandler: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            Notificare.shared.sendNotificationReply(action, for: notification) { _ in }

        case .cancelled:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didNotExecuteAction: action, for: notification)

        case .failed:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.failed)

        default:
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.failed)
        }

        dismiss()
    }
}

public extension NotificareSmsActionHandler {
    enum ActionError: LocalizedError {
        case notSupported
        case failed

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support sending a SMS."
            case .failed:
                return "The message composer failed to send the SMS."
            }
        }
    }
}
