//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import MessageUI
import NotificareCore
import NotificareKit
import NotificarePushKit
import StoreKit
import UIKit

public class NotificarePushUI {
    public static let shared = NotificarePushUI()

    public weak var delegate: NotificarePushUIDelegate?

    private var latestPresentableActionHandler: NotificareBaseActionHandler?

//    func presentNotification(_ notification: NotificareNotification, in controller: UIViewController) {}
//
//    func presentNotification(_ notification: NotificareNotification, in window: UIWindow) {}
//
//    func presentNotification(_ notification: NotificareNotification, in scene: UIWindowScene) {}
//
//    func presentNotification(_ notification: NotificareNotification, in controller: UINavigationController) {}
//
//    func presentNotification(_ notification: NotificareNotification, in controller: UITabBarController, for tab: UITabBarItem) {}

    public func presentNotification(_ notification: NotificareNotification, in controller: UIViewController) {
        NotificareLogger.debug("Presenting notification '\(notification.id)'.")

        guard let type = NotificareNotification.NotificationType(rawValue: notification.type) else {
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
            let notificationController = NotificareUrlViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)

        case .urlScheme:
            presentUrlSchemeNotification(notification)

        case .rate:
            presentRateNotification(notification, in: controller)

        case .image:
            let notificationController = NotificareImageGalleryViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)

        case .map:
            let notificationController = NotificareMapViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)

        case .passbook:
            // TODO: handle passbook notification
            break

        case .store:
            if let presentableController = NotificareStoreController.shared.createViewController(for: notification) {
                presentController(presentableController, in: controller)
            }

        case .video:
            let notificationController = NotificareVideoViewController()
            notificationController.notification = notification

            presentController(notificationController, in: controller)
        }
    }

    private func presentAlertNotification(_ notification: NotificareNotification, in controller: UIViewController) {
        let alert = UIAlertController(title: notification.title, message: notification.message, preferredStyle: .alert)

        notification.actions.forEach { action in
            alert.addAction(
                UIAlertAction(title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                              style: .default,
                              handler: { _ in
                                  NotificareBaseNotificationViewController.handleAction(action, for: notification)
                              })
            )
        }

        let useCancelButton = !notification.actions.isEmpty
        alert.addAction(UIAlertAction(title: NotificareLocalizable.string(resource: useCancelButton ? .cancel : .ok),
                                      style: useCancelButton ? .cancel : .default,
                                      handler: { _ in
                                          // TODO: [[self delegate] notificationType:self didCloseNotification:[self notification]];
                                      }))

        presentController(alert, in: controller)
    }

    private func presentUrlSchemeNotification(_ notification: NotificareNotification) {
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

    private func presentRateNotification(_ notification: NotificareNotification, in controller: UIViewController) {
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

        presentController(alert, in: controller)
    }

    func presentController(_ controller: UIViewController, in originController: UIViewController) {
        if controller is UIAlertController || controller is SKStoreProductViewController || controller is UINavigationController {
            if originController.presentedViewController != nil {
                originController.dismiss(animated: true) {
                    originController.present(controller, animated: true)
                }
            } else {
                originController.present(controller, animated: true)
            }

            return
        }

        if let navigationController = originController as? UINavigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            originController.present(controller, animated: true, completion: nil)
        }
    }

    public func presentAction(_ action: NotificareNotification.Action, for notification: NotificareNotification, with response: NotificareNotification.ResponseData?, in controller: UIViewController) {
        NotificareLogger.debug("Presenting notification action '\(action.type)' for notification '\(notification.id)'.")

        guard let type = NotificareNotification.Action.ActionType(rawValue: action.type) else {
            NotificareLogger.warning("Unhandled notification action type '\(action.type)'.")
            return
        }

        switch type {
        case .app:
            latestPresentableActionHandler = NotificareAppActionHandler(notification: notification,
                                                                        action: action)
        case .browser:
            latestPresentableActionHandler = NotificareBrowserActionHandler(notification: notification,
                                                                            action: action)
        case .callback:
            latestPresentableActionHandler = NotificareCallbackActionHandler(notification: notification,
                                                                             action: action,
                                                                             response: response,
                                                                             sourceViewController: controller)
        case .custom:
            latestPresentableActionHandler = NotificareCustomActionHandler(notification: notification,
                                                                           action: action)
        case .mail:
            latestPresentableActionHandler = NotificareMailActionHandler(notification: notification,
                                                                         action: action,
                                                                         sourceViewController: controller)
        case .sms:
            latestPresentableActionHandler = NotificareSmsActionHandler(notification: notification,
                                                                        action: action,
                                                                        sourceViewController: controller)
        case .telephone:
            latestPresentableActionHandler = NotificareTelephoneActionHandler(notification: notification,
                                                                              action: action)
        }

        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, willExecuteAction: action, for: notification)
        latestPresentableActionHandler?.execute()
    }
}
