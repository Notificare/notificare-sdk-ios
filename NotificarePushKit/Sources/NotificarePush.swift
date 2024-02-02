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

    func enableRemoteNotifications() async throws -> Bool

    func disableRemoteNotifications()

    func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool

    @available(*, deprecated, message: "Include the NotificareNotificationServiceExtensionKit and use NotificareNotificationServiceExtension.handleNotificationRequest() instead.")
    func handleNotificationRequest(_ request: UNNotificationRequest, _ completion: @escaping NotificareCallback<UNNotificationContent>)

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String], _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String]) async throws

    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String) async throws
}

public extension NotificarePush {
    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, _ completion: @escaping NotificareCallback<Void>) {
        registerLiveActivity(activityId, token: token, topics: [], completion)
    }

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String) async throws {
        try await registerLiveActivity(activityId, token: token, topics: [])
    }

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = [], _ completion: @escaping NotificareCallback<Void>) {
        registerLiveActivity(activityId, token: token.toHexString(), topics: topics, completion)
    }

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = []) async throws {
        try await registerLiveActivity(activityId, token: token.toHexString(), topics: topics)
    }
}

public protocol NotificarePushUIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data)

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult
}

public protocol NotificarePushUNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
}
