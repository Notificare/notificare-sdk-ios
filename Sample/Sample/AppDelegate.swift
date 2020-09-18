//
//  AppDelegate.swift
//  Sample
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import UIKit
import Notificare

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificareDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Notificare.shared.logger.level = .verbose
        Notificare.shared.delegate = self

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {}

    // MARK: - NotificareDelegate

    func notificare(_ notificare: Notificare, onReady application: NotificareApplicationInfo) {
        print("-----> Notificare is ready.")
    }

    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}
