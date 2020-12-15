//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import NotificareSDK
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

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any]) {}

    // MARK: - NotificareDelegate

    func notificare(_: Notificare, onReady _: NotificareApplication) {
        print("-----> Notificare is ready.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}
