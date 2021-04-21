//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import NotificareInboxKit
import NotificareKit
import NotificarePushKit
import NotificarePushUIKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        Atlantis.start()

        Notificare.shared.useAdvancedLogging = true
        Notificare.shared.launchOptions = launchOptions

        if #available(iOS 14.0, *) {
            NotificarePush.shared.presentationOptions = [.banner, .badge, .sound]
        } else {
            NotificarePush.shared.presentationOptions = [.alert, .badge, .sound]
        }

        Notificare.shared.delegate = self
        NotificarePush.shared.delegate = self
        NotificarePushUI.shared.delegate = self
        NotificareInbox.shared.delegate = self

        Notificare.shared.configure()
        Notificare.shared.launch()

        return true
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
    func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("-----> Notificare: failed to register for remote notifications: \(error)")
    }

    func notificare(_: NotificarePush, didChangeNotificationSettings granted: Bool) {
        print("-----> Notificare: notification settings changed: \(granted)")
    }

    func notificare(_: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification) {
        print("-----> Notificare: received a system notification: \(notification)")
    }

    func notificare(_: NotificarePush, didReceiveNotification notification: NotificareNotification) {
        print("-----> Notificare: received a notification: \(notification)")
    }

    func notificare(_: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        print("-----> Notificare: received an unknown notification: \(userInfo)")
    }

    func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {
        print("-----> Notificare: should open notification settings")
    }

    func notificare(_: NotificarePush, didReceiveUnknownAction action: [AnyHashable: Any], for _: [AnyHashable: Any]) {
        print("-----> Notificare: received an unknown action: \(action)")
    }

    func notificare(_: NotificarePush, didOpenNotification notification: NotificareNotification) {
        //        guard let controller = window?.rootViewController else {
        //            return
        //        }

        guard let scene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first ?? UIApplication.shared.connectedScenes.first,
              let window = (scene.delegate as! UIWindowSceneDelegate).window!,
              let rootViewController = window.rootViewController
        else {
            return
        }

        NotificarePushUI.shared.presentNotification(notification, in: rootViewController)
    }

    func notificare(_: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification, with response: NotificareNotification.ResponseData?) {
//        guard let controller = window?.rootViewController else {
//            return
//        }

        guard let scene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first ?? UIApplication.shared.connectedScenes.first,
              let window = (scene.delegate as! UIWindowSceneDelegate).window!,
              let rootViewController = window.rootViewController
        else {
            return
        }

        NotificarePushUI.shared.presentAction(action, for: notification, with: response, in: rootViewController)
    }
}

extension AppDelegate: NotificarePushUIDelegate {
    func notificare(_: NotificarePushUI, willPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: will present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did fail to present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification) {
        print("-----> Notificare: did finish presenting notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification) {
        print("-----> Notificare: did click url '\(url)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: will execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error _: Error?) {
        print("-----> Notificare: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, shouldPerformSelectorWithURL _: URL, in _: NotificareNotification.Action, for _: NotificareNotification) {
        //
    }
}

extension AppDelegate: NotificareInboxDelegate {
    func notificare(_: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        print("-----> Inbox has loaded. Total = \(items.count)")
    }

    func notificare(_: NotificareInbox, didUpdateBadge badge: Int) {
        print("-----> Badge update. Unread = \(badge)")
    }
}
