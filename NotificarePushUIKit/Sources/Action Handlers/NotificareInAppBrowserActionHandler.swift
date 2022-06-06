//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import SafariServices
import UIKit

public class NotificareInAppBrowserActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        if let target = action.target, let url = URL(string: target) {
            DispatchQueue.main.async {
                let theme = Notificare.shared.options?.theme(for: self.sourceViewController)
                let safariViewController = Notificare.shared.pushUIImplementation().createSafariViewController(url: url, theme: theme)
                safariViewController.delegate = self

                self.sourceViewController.presentOrPush(safariViewController)
            }
        } else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: ActionError.invalidUrl)
        }
    }
}

extension NotificareInAppBrowserActionHandler: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        if successfully {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: action, for: notification)
            Notificare.shared.createNotificationReply(notification: notification, action: action) { _ in }
        } else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: nil)
        }
    }
}

public extension NotificareInAppBrowserActionHandler {
    enum ActionError: LocalizedError {
        case invalidUrl

        public var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "The target of the action is not a valid URL."
            }
        }
    }
}
