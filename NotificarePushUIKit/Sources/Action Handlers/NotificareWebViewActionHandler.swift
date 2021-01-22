//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import SafariServices
import UIKit

public class NotificareWebViewActionHandler: NotificareBaseActionHandler {
    private let sourceViewController: UIViewController

    init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController

        super.init(notification: notification, action: action)
    }

    override func execute() {
        if let target = action.target, let url = URL(string: target) {
            DispatchQueue.main.async {
                let safariViewController: SFSafariViewController

                if #available(iOS 11.0, *) {
                    let configuration = SFSafariViewController.Configuration()
                    configuration.entersReaderIfAvailable = true

                    safariViewController = SFSafariViewController(url: url, configuration: configuration)
                } else {
                    safariViewController = SFSafariViewController(url: url)
                }

                safariViewController.delegate = self

                if let configuration = NotificareUtils.getConfiguration(), let theme = configuration.theme(for: self.sourceViewController) {
                    if let colorStr = theme.safariBarTintColor {
                        safariViewController.preferredBarTintColor = UIColor(hexString: colorStr)
                    }

                    if let colorStr = theme.safariControlsTintColor {
                        safariViewController.preferredControlTintColor = UIColor(hexString: colorStr)
                    }

                    if #available(iOS 11.0, *) {
                        if let styleInt = configuration.options?.safariDismissButtonStyle,
                           let style = SFSafariViewController.DismissButtonStyle(rawValue: styleInt)
                        {
                            safariViewController.dismissButtonStyle = style
                        }
                    }
                }

                NotificarePushUI.shared.presentController(safariViewController, in: self.sourceViewController)
            }
        } else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.invalidUrl)
        }
    }
}

extension NotificareWebViewActionHandler: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        if successfully {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            Notificare.shared.sendNotificationReply(action, for: notification) { _ in }
        } else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: nil)
        }
    }
}

public extension NotificareWebViewActionHandler {
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
