//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import NotificareKit
import NotificarePushKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificareDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Notificare.shared.logger.level = .verbose
        Notificare.shared.delegate = self

        // Enable Proxyman debugging.
        Atlantis.start()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        print("-----> didRegisterForRemoteNotificationsWithDeviceToken: \(token.toHexString())")
        NotificarePush.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("-----> didFailToRegisterForRemoteNotificationsWithError: \(error)")
        NotificarePush.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("-----> didReceiveRemoteNotification: \(userInfo)")
        NotificarePush.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    // MARK: - NotificareDelegate

    func notificare(_: Notificare, onReady _: NotificareApplication) {
        print("-----> Notificare is ready.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}
