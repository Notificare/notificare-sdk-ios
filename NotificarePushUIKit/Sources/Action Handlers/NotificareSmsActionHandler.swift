//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareCore
import NotificarePushKit

class NotificareSmsActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        guard let target = action.target, MFMessageComposeViewController.canSendText() else {
            // TODO: FAIL
            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = recipients
        composer.body = ""

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

extension NotificareSmsActionHandler: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
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
