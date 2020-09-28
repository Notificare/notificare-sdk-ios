//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificareDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Notificare.shared.logger.level = .verbose
        Notificare.shared.delegate = self

        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any]) {}

    // MARK: - NotificareDelegate

    func notificare(_: Notificare, onReady _: NotificareApplicationInfo) {
        print("-----> Notificare is ready.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}
