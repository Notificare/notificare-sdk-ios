//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareKit
import NotificareUtilitiesKit

public class NotificareSmsActionHandler: NotificareBaseActionHandler {
    internal override func execute() {
        guard let target = action.target, MFMessageComposeViewController.canSendText() else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }

            return
        }

        let recipients = target.components(separatedBy: ",")

        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = recipients
        composer.body = ""

        sourceViewController.presentOrPush(composer)
    }
}

extension NotificareSmsActionHandler: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .sent:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

            Task {
                try? await Notificare.shared.createNotificationReply(notification: notification, action: action)
            }

        case .cancelled:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didNotExecuteAction: self.action, for: self.notification)
            }

        case .failed:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.failed)
            }

        default:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.failed)
            }
        }

        dismiss()
    }
}

extension NotificareSmsActionHandler {
    public enum ActionError: LocalizedError {
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
