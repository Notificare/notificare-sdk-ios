//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import NotificarePushKit
import StoreKit
import UIKit

public class NotificarePushUI {
    private init() {}

//    static func presentNotification(_ notification: NotificareNotification, in controller: UIViewController) {}
//
//    static func presentNotification(_ notification: NotificareNotification, in window: UIWindow) {}
//
//    static func presentNotification(_ notification: NotificareNotification, in scene: UIWindowScene) {}
//
//    static func presentNotification(_ notification: NotificareNotification, in controller: UINavigationController) {}
//
//    static func presentNotification(_ notification: NotificareNotification, in controller: UITabBarController, for tab: UITabBarItem) {}

    public static func presentNotification(_ notification: NotificareNotification, in controller: UIViewController) {
        NotificareLogger.debug("Presenting notification '\(notification.id)'.")

        guard let type = Notificare.NotificationType(rawValue: notification.type) else {
            NotificareLogger.warning("Unhandled notification type '\(notification.type)'.")
            return
        }

        switch type {
        case .none:
            NotificareLogger.debug("Attempting to present a notification of type 'none'. These should be handled by the application instead.")

        case .alert:
            presentAlertNotification(notification, in: controller)

        case .webView:
            let notificationController = NotificareWebViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)

        case .url:
            break

        case .urlScheme:
            presentUrlSchemeNotification(notification, in: controller)

        case .rate:
            presentRateNotification(notification, in: controller)

        case .image:
            let notificationController = NotificareImageGalleryViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)

        case .map:
            break

        case .passbook:
            break

        case .store:
            break

        case .video:
            let notificationController = NotificareVideoViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)
        }
    }

    private static func presentAlertNotification(_ notification: NotificareNotification, in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title, message: notification.message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: .ok),
                                      style: .default,
                                      handler: nil))

        controller.present(alert, animated: true, completion: nil)
    }

    private static func presentMapNotification() {}

    private static func presentStoreNotification() {}

    private static func presentUrlSchemeNotification(_ notification: NotificareNotification, in _: UIViewController) {
        if let content = notification.content.first,
           let urlStr = content.data as? String
        {
            if urlStr.contains("ntc.re") {
                // It's an universal link from Notificare, let's get the target.
                Notificare.shared.fetchDynamicLink(urlStr) { result in
                    switch result {
                    case let .success(link):
                        if let url = URL(string: link.target) {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    case .failure:
                        break
                    }
                }
            } else {
                // It's a non-universal link from Notificare, let's just try and open it.
                if let url = URL(string: urlStr) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }

    private static func presentRateNotification(_ notification: NotificareNotification, in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title, message: notification.message, preferredStyle: .alert)

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

        controller.present(alert, animated: true, completion: nil)
    }

    private static func presentController(_ controller: UIViewController, in originController: UIViewController) {
        if let navigationController = originController as? UINavigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            originController.present(controller, animated: true, completion: nil)
        }
    }
}
