//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareKit
import NotificareUtilitiesKit

public class NotificareMailActionHandler: NotificareBaseActionHandler {
    internal override func execute() {
        guard let target = action.target, MFMailComposeViewController.canSendMail() else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.notSupported)
            }

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
}

extension NotificareMailActionHandler: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .saved, .sent:
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
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
            }

        default:
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: error)
            }
        }

        dismiss()
    }
}

extension NotificareMailActionHandler {
    public enum ActionError: LocalizedError {
        case notSupported

        public var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The device does not support sending an email."
            }
        }
    }
}
