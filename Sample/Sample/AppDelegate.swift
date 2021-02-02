//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import NotificareCore
import NotificareKit
import NotificarePushKit
import NotificarePushUIKit
import NotificareInboxKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        Atlantis.start()

        NotificareLogger.useAdvancedLogging = true

        if #available(iOS 14.0, *) {
            NotificarePush.shared.presentationOptions = [.banner, .badge, .sound]
        } else {
            NotificarePush.shared.presentationOptions = [.alert, .badge, .sound]
        }
        
        Notificare.shared.delegate = self
        NotificarePush.shared.delegate = self
        NotificarePushUI.shared.delegate = self
        NotificareInbox.shared.delegate = self

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        NotificarePush.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificarePush.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificarePush.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
}

extension AppDelegate: NotificareDelegate {

    func notificare(_: Notificare, onReady _: NotificareApplication) {
        NotificareLogger.info("-----> Notificare is ready.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        NotificareLogger.info("-----> Notificare: device registered: \(device)")
    }
}

extension AppDelegate: NotificarePushDelegate {

    func notificare(_ notificarePush: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificareLogger.info("-----> Notificare: failed to register for remote notifications: \(error)")
    }

    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings granted: Bool) {
        NotificareLogger.info("-----> Notificare: notification settings changed: \(granted)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification) {
        NotificareLogger.info("-----> Notificare: received a system notification: \(notification)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveNotification notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: received a notification: \(notification)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable : Any]) {
        NotificareLogger.info("-----> Notificare: received an unknown notification: \(userInfo)")
    }

    func notificare(_ notificarePush: NotificarePush, shouldOpenSettings notification: NotificareNotification?) {
        NotificareLogger.info("-----> Notificare: should open notification settings")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownAction action: [AnyHashable : Any], for notification: [AnyHashable : Any]) {
        NotificareLogger.info("-----> Notificare: received an unknown action: \(action)")
    }
    
    func notificare(_ notificarePush: NotificarePush, didOpenNotification notification: NotificareNotification) {
        guard let controller = window?.rootViewController else {
            return
        }

        NotificarePushUI.shared.presentNotification(notification, in: controller)
    }
    
    func notificare(_ notificarePush: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification, with response: NotificareNotification.ResponseData?) {
        guard let controller = window?.rootViewController else {
            return
        }

        NotificarePushUI.shared.presentAction(action, for: notification, with: response, in: controller)
    }
}

extension AppDelegate: NotificarePushUIDelegate {
    func notificare(_ notificarePushUI: NotificarePushUI, willPresentNotification notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: will present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didPresentNotification notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did fail to present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did finish presenting notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did click url '\(url)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: will execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        NotificareLogger.info("-----> Notificare: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error: Error?) {
        NotificareLogger.info("-----> Notificare: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, shouldPerformSelectorWithURL url: URL, in action: NotificareNotification.Action, for notification: NotificareNotification) {
        //
    }
}

extension AppDelegate: NotificareInboxDelegate {
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        NotificareLogger.info("-----> Inbox has loaded. Total = \(items.count)")
    }
    
    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int) {
        NotificareLogger.info("-----> Badge update. Unread = \(badge)")
    }
}
