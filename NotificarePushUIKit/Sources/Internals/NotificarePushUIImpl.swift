//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import SafariServices
import StoreKit
import UIKit

internal class NotificarePushUIImpl: NotificareModule, NotificarePushUI {
    private var latestPresentableNotificationHandler: NotificareNotificationPresenter?
    private var latestPresentableActionHandler: NotificareBaseActionHandler?

    // MARK: - Notificare Module

    internal static let instance = NotificarePushUIImpl()

    // MARK: - Notificare Push UI

    public weak var delegate: NotificarePushUIDelegate?

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

        case .inAppBrowser:
            latestPresentableNotificationHandler = NotificareInAppBrowserController(notification: notification)

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
            if
                NotificareInternals.Module.loyalty.isAvailable,
                let integration = NotificareInternals.Module.loyalty.klass?.instance as? NotificareLoyaltyIntegration,
                integration.canPresentPasses
            {
                integration.present(notification: notification, in: controller)
                return
            }

            let notificationController = NotificareWebPassViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController

        case .store:
            latestPresentableNotificationHandler = NotificareStoreController(notification: notification)

        case .video:
            let notificationController = NotificareVideoViewController()
            notificationController.notification = notification

            latestPresentableNotificationHandler = notificationController
        }

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), willPresentNotification: notification)
        }

        latestPresentableNotificationHandler?.present(in: controller)
    }

    public func presentAction(_ action: NotificareNotification.Action, for notification: NotificareNotification, in controller: UIViewController) {
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
        case .webView, .inAppBrowser:
            latestPresentableActionHandler = NotificareInAppBrowserActionHandler(notification: notification,
                                                                                 action: action,
                                                                                 sourceViewController: controller)
        }

        DispatchQueue.main.async {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), willExecuteAction: action, for: notification)
        }

        latestPresentableActionHandler?.execute()
    }

    internal func createSafariViewController(url: URL, theme: NotificareOptions.Theme?) -> SFSafariViewController {
        let safariViewController: SFSafariViewController

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true

            safariViewController = SFSafariViewController(url: url, configuration: configuration)
        } else {
            safariViewController = SFSafariViewController(url: url)
        }

        if let theme = theme {
            if let colorStr = theme.safariBarTintColor {
                safariViewController.preferredBarTintColor = UIColor(hexString: colorStr)
            }

            if let colorStr = theme.safariControlsTintColor {
                safariViewController.preferredControlTintColor = UIColor(hexString: colorStr)
            }

            if #available(iOS 11.0, *) {
                if
                    let styleInt = Notificare.shared.options!.safariDismissButtonStyle,
                    let style = SFSafariViewController.DismissButtonStyle(rawValue: styleInt)
                {
                    safariViewController.dismissButtonStyle = style
                }
            }
        }

        return safariViewController
    }
}
