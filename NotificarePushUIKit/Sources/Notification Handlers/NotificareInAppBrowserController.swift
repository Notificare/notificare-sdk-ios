//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit
import SafariServices
import UIKit

class NotificareInAppBrowserController: NSObject, NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in controller: UIViewController) {
        guard let content = notification.content.first,
              let urlStr = content.data as? String,
              let url = URL(string: urlStr)
        else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
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
        if successfully {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: notification)
        } else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
        }
    }

    public func safariViewControllerDidFinish(_: SFSafariViewController) {
        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: notification)
    }
}
