//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit
import UserNotifications

public protocol NotificarePush: AnyObject, NotificarePushUIApplicationDelegate, NotificarePushUNUserNotificationCenterDelegate {
    // MARK: Properties

    var delegate: NotificarePushDelegate? { get set }

    var authorizationOptions: UNAuthorizationOptions { get set }

    var categoryOptions: UNNotificationCategoryOptions { get set }

    var presentationOptions: UNNotificationPresentationOptions { get set }

    var hasRemoteNotificationsEnabled: Bool { get }

    var allowedUI: Bool { get }

    // MARK: Methods

    func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>)

    func disableRemoteNotifications()

    func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool

    @available(*, deprecated, message: "Include the NotificareNotificationServiceExtensionKit and use NotificareNotificationServiceExtension.handleNotificationRequest() instead.")
    func handleNotificationRequest(_ request: UNNotificationRequest, _ completion: @escaping NotificareCallback<UNNotificationContent>)
}

public protocol NotificarePushUIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data)

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

public protocol NotificarePushUNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
}
