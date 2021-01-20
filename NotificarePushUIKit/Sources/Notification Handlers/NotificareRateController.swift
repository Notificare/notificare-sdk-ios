//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import NotificarePushKit
import StoreKit
import UIKit

class NotificareRateController: NotificareNotificationPresenter {
    private let notification: NotificareNotification

    init(notification: NotificareNotification) {
        self.notification = notification
    }

    func present(in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title ?? NotificareUtils.applicationName,
                                      message: notification.message,
                                      preferredStyle: .alert)

        // Rate action
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: .rateAlertYesButton), style: .default, handler: { _ in
            if #available(iOS 10.3, *), !NotificareUserDefaults.hasReviewedCurrentVersion {
//                if #available(iOS 14.0, *), let scene = scene {
//                    SKStoreReviewController.requestReview(in: scene)
//                } else {
                SKStoreReviewController.requestReview()
//                }

                NotificareUserDefaults.hasReviewedCurrentVersion = true
            } else {
                // Go to the Store instead
                if let appStoreId = Notificare.shared.application?.appStoreId,
                   let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)?action=write-review")
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else {
                    NotificareLogger.warning("Cannot open the App Store.")
                }
            }
        }))

        // Cancel action
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: .rateAlertNoButton), style: .default, handler: nil))

        NotificarePushUI.shared.presentController(alert, in: controller)
    }
}
