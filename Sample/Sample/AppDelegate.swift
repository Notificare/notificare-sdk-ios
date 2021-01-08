//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import NotificareCore
import NotificareKit
import NotificarePushKit
import NotificarePushUIKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        Atlantis.start()

        NotificareLogger.useAdvancedLogging = true
        Notificare.shared.delegate = self

        if #available(iOS 14.0, *) {
            NotificarePush.shared.presentationOptions = [.banner, .badge, .sound]
        } else {
            NotificarePush.shared.presentationOptions = [.alert, .badge, .sound]
        }
        NotificarePush.shared.delegate = self

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        NotificareLogger.info("-----> didRegisterForRemoteNotificationsWithDeviceToken")
        NotificarePush.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificareLogger.info("-----> didFailToRegisterForRemoteNotificationsWithError")
        NotificarePush.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificareLogger.info("-----> didReceiveRemoteNotification")
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

        NotificarePushUI.presentNotification(notification, in: controller)
    }
}
