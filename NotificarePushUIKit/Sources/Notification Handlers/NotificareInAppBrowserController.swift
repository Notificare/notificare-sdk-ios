//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit
import SafariServices
import UIKit

internal class NotificareInAppBrowserController: NSObject, NotificareNotificationPresenter {
    private let notification: NotificareNotification

    internal init(notification: NotificareNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        guard let content = notification.content.first,
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)?.removingQueryComponent(name: "notificareWebView"),
              url.isHttpUrl
        else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }

            return
        }

        let theme = Notificare.shared.options?.theme(for: controller)
        let safariViewController = Notificare.shared.pushUIImplementation().createSafariViewController(url: url, theme: theme)
        safariViewController.delegate = self

        controller.presentOrPush(safariViewController)
    }
}

extension NotificareInAppBrowserController: SFSafariViewControllerDelegate {
    public func safariViewController(_: SFSafariViewController, didCompleteInitialLoad successfully: Bool) {
        DispatchQueue.main.async {
            if successfully {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
            } else {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: self.notification)
            }
        }
    }

    public func safariViewControllerDidFinish(_: SFSafariViewController) {
        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
        }
    }
}
