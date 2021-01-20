//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import NotificarePushKit
import StoreKit
import UIKit

public class NotificarePushUI {
    public static let shared = NotificarePushUI()

    public weak var delegate: NotificarePushUIDelegate?

    private var latestPresentableNotificationHandler: NotificareNotificationPresenter?
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
            return

        case .alert:
            latestPresentableNotificationHandler = NotificareAlertController(notification: notification)

        case .webView:
            let notificationController = NotificareWebViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .url:
            let notificationController = NotificareUrlViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .urlScheme:
            latestPresentableNotificationHandler = NotificareUrlSchemeController(notification: notification)

        case .rate:
            latestPresentableNotificationHandler = NotificareRateController(notification: notification)

        case .image:
            let notificationController = NotificareImageGalleryViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .map:
            let notificationController = NotificareMapViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .passbook:
            // TODO: handle passbook notification
            break

        case .store:
            latestPresentableNotificationHandler = NotificareStoreController(notification: notification)

        case .video:
            let notificationController = NotificareVideoViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController
        }

        // TODO: delegate will present
        latestPresentableNotificationHandler?.present(in: controller)
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

    // MARK: - Internal API

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
}
