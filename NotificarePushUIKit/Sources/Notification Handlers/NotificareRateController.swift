//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit
import StoreKit
import UIKit

internal class NotificareRateController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    internal init(notification: NotificareNotification) {
        self.notification = notification
    }

    internal func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? ApplicationUtils.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        // Rate action
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: .rateAlertYesButton), style: .default, handler: { _ in
            if #available(iOS 10.3, *), !LocalStorage.hasReviewedCurrentVersion {
//                if #available(iOS 14.0, *), let scene = scene {
//                    SKStoreReviewController.requestReview(in: scene)
//                } else {
                SKStoreReviewController.requestReview()
//                }

                LocalStorage.hasReviewedCurrentVersion = true
            } else {
                // Go to the Store instead
                if
                    let appStoreId = Notificare.shared.application?.appStoreId,
                    let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)?action=write-review")
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else {
                    NotificareLogger.warning("Cannot open the App Store.")
                }
            }

            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
            }
        }))

        // Cancel action
        alert.addAction(
            UIAlertAction(title: NotificareLocalizable.string(resource: .rateAlertNoButton),
                          style: .default,
                          handler: { _ in
                              DispatchQueue.main.async {
                                  Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: self.notification)
                              }
                          })
        )

        controller.presentOrPush(alert) {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: self.notification)
            }
        }
    }
}
