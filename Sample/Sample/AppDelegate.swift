//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
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

        Notificare.shared.useAdvancedLogging = true
        
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
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        NotificarePush.shared.userNotificationCenter(center, openSettingsFor: notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificarePush.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificarePush.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}

extension AppDelegate: NotificareDelegate {

    func notificare(_: Notificare, onReady _: NotificareApplication) {
        print("-----> Notificare is ready.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}

extension AppDelegate: NotificarePushDelegate {

    func notificare(_ notificarePush: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("-----> Notificare: failed to register for remote notifications: \(error)")
    }

    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings granted: Bool) {
        print("-----> Notificare: notification settings changed: \(granted)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification) {
        print("-----> Notificare: received a system notification: \(notification)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveNotification notification: NotificareNotification) {
        print("-----> Notificare: received a notification: \(notification)")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable : Any]) {
        print("-----> Notificare: received an unknown notification: \(userInfo)")
    }

    func notificare(_ notificarePush: NotificarePush, shouldOpenSettings notification: NotificareNotification?) {
        print("-----> Notificare: should open notification settings")
    }

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownAction action: [AnyHashable : Any], for notification: [AnyHashable : Any]) {
        print("-----> Notificare: received an unknown action: \(action)")
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
        print("-----> Notificare: will present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did fail to present notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification) {
        print("-----> Notificare: did finish presenting notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification) {
        print("-----> Notificare: did click url '\(url)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: will execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error: Error?) {
        print("-----> Notificare: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }
    
    func notificare(_ notificarePushUI: NotificarePushUI, shouldPerformSelectorWithURL url: URL, in action: NotificareNotification.Action, for notification: NotificareNotification) {
        //
    }
}

extension AppDelegate: NotificareInboxDelegate {
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        print("-----> Inbox has loaded. Total = \(items.count)")
    }
    
    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int) {
        print("-----> Badge update. Unread = \(badge)")
    }
}
