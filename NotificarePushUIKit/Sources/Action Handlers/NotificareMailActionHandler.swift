//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareCore
import NotificarePushKit

class NotificareMailActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        guard let target = action.target, MFMailComposeViewController.canSendMail() else {
            // TODO: FAIL
            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(recipients)
        composer.setSubject(NotificareLocalizable.string(resource: .actionMailSubject))
        composer.setMessageBody(NotificareLocalizable.string(resource: .actionMailBody), isHTML: false)

        NotificarePushUI.presentController(composer, in: sourceViewController)
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
    func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error _: Error?) {
        switch result {
        case .saved, .sent:
            // [[self delegate] actionType:self didExecuteAction:[self action]];
            NotificarePush.shared.submitNotificationActionReply(action, for: notification) { _ in }

        case .cancelled:
            break

        case .failed:
            // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:e];
            break

        default:
            // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:e];
            break
        }

        dismiss()
    }
}
