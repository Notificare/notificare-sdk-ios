//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import SafariServices
import UIKit

public class NotificareInAppBrowserActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    internal init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    internal override func execute() {
        if let target = action.target, let url = URL(string: target) {
            DispatchQueue.main.async {
                let theme = Notificare.shared.options?.theme(for: self.sourceViewController)
                let safariViewController = Notificare.shared.pushUIImplementation().createSafariViewController(url: url, theme: theme)
                safariViewController.delegate = self

                self.sourceViewController.presentOrPush(safariViewController)
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.invalidUrl)
            }
        }
    }
}

extension NotificareInAppBrowserActionHandler: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        if successfully {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

            Task {
                try? await Notificare.shared.createNotificationReply(notification: notification, action: action)
            }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: nil)
            }
        }
    }
}

extension NotificareInAppBrowserActionHandler {
    public enum ActionError: LocalizedError {
        case invalidUrl

        public var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "The target of the action is not a valid URL."
            }
        }
    }
}
