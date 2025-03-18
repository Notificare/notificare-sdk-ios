//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Combine
import Foundation
import NotificareKit
import UIKit
import UserNotifications

public protocol NotificarePush: AnyObject, NotificarePushUIApplicationDelegate, NotificarePushUNUserNotificationCenterDelegate {
    // MARK: Properties

    /// Specifies the delegate that handles push notifications events
    ///
    /// This property allows setting a delegate conforming to ``NotificarePushDelegate`` to respond to various push notification events,
    /// such as receiving, opening, or interacting with notifications.
    var delegate: NotificarePushDelegate? { get set }

    /// Defines the authorization options used when requesting push notification permissions.
    var authorizationOptions: UNAuthorizationOptions { get set }

    /// Defines the notification category options for custom notification actions.
    var categoryOptions: UNNotificationCategoryOptions { get set }

    /// Defines the presentation options for displaying notifications while the app is in the foreground.
    var presentationOptions: UNNotificationPresentationOptions { get set }

    /// Indicates whether remote notifications are enabled.
    ///
    /// This property returns `true` if remote notifications are enabled for the application, and `false` otherwise.
    ///
    var hasRemoteNotificationsEnabled: Bool { get }

    /// Provides the current push transport information.
    ///
    /// This property returns the ``NotificareTransport`` assigned to the device.
    ///
    var transport: NotificareTransport? { get }

    /// Provides the current push subscription token.
    ///
    /// This property returns the ``NotificarePushSubscription`` object containing the device's current push subscription
    /// token, or `nil` if no token is available.
    ///
    var subscription: NotificarePushSubscription? { get }

    /// This property returns a Publisher that can be observed to track changes to the device's push subscription token.
    var subscriptionStream: AnyPublisher<NotificarePushSubscription?, Never> { get }

    /// Indicates whether the device is capable of receiving remote notifications.
    ///
    /// This property returns `true` if the user has granted permission to receive push notifications and the device
    /// has successfully obtained a push token from the notification service. It reflects whether the app can present
    /// notifications as allowed by the system and user settings.
    var allowedUI: Bool { get }

    /// This property returns a Publisher that can be observed to track any changes to whether the device can receive remote notifications.
    var allowedUIStream: AnyPublisher<Bool, Never> { get }

    // MARK: Methods

    /// Enables remote notifications, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the enable notifications operation.
    func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>)

    /// Enables remote notifications.
    ///
    /// - Returns: `true`if the remote notifications were enabled, `false` otherwise.
    func enableRemoteNotifications() async throws -> Bool

    /// Disables remote notifications, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the disable notifications operation.
    func disableRemoteNotifications(_ completion: @escaping NotificareCallback<Void>)

    /// Disables remote notifications.
    func disableRemoteNotifications() async throws

    /// Determines whether a remote message is a Notificare notification.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary containing the payload data of the notification.
    ///
    /// - Returns: `true` if the message is a Notificare notification, `false` otherwise.
    func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool

    /// Registers a live activity categorized by a list of topics, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String], _ completion: @escaping NotificareCallback<Void>)

    /// Registers a live activity categorized by a list of topics.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String]) async throws

    /// Ends a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to end.
    ///   - completion: A callback that will be invoked with the result of the end live activity operation.
    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String, _ completion: @escaping NotificareCallback<Void>)

    /// Ends a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to end.
    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String) async throws
}

extension NotificarePush {
    /// Registers a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String, _ completion: @escaping NotificareCallback<Void>) {
        registerLiveActivity(activityId, token: token, topics: [], completion)
    }

    /// Registers a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String) async throws {
        try await registerLiveActivity(activityId, token: token, topics: [])
    }

    /// Registers a live activity, with a callback.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    ///   - completion: A callback that will be called with the result of the register live activity operation.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = [], _ completion: @escaping NotificareCallback<Void>) {
        registerLiveActivity(activityId, token: token.toHexString(), topics: topics, completion)
    }

    /// Registers a live activity.
    ///
    /// - Parameters:
    ///   - activityId: The ID of the live activity to register.
    ///   - token: The current subscription token.
    ///   - topics: A list of topics to subscribe to.
    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: Data, topics: [String] = []) async throws {
        try await registerLiveActivity(activityId, token: token.toHexString(), topics: topics)
    }
}

public protocol NotificarePushUIApplicationDelegate {
    /// Called when the app successfully registers with Apple Push Notification Service (APNS).
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - token:  The device token data for remote notifications.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data)

    /// Called when the app fails to register for remote notifications.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - error: An error object describing why registration failed.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)

    /// Called when a remote notification is received. Used to handle notification content and initiate background processing if necessary.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - userInfo: The payload of the received remote notification.
    ///   - completionHandler: A handler to be called with a `UIBackgroundFetchResult` after processing the notification.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    /// Called when a remote notification is received. Provides async support for handling the notification.
    ///
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - userInfo: The payload of the received remote notification.
    ///
    /// - Returns: A `UIBackgroundFetchResult` indicating the result of the background fetch operation.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult
}

public protocol NotificarePushUNUserNotificationCenterDelegate {
    /// Called when a notification prompts the app to open its settings screen.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification that prompted the settings to be opened, if applicable.
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?)

    /// Called when the user interacts with a notification.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - response: The user’s response to the notification.
    ///   - completionHandler: A completion handler to call after processing the response.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)

    /// Called asynchronously when the user interacts with a notification.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - response: The user’s response to the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async

    /// Called when a notification is delivered to the app while it’s in the foreground.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification being presented.
    ///   - completionHandler: A completion handler to call with the desired presentation options.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

    /// Called asynchronously when a notification is delivered to the app while it’s in the foreground.
    ///
    /// - Parameters:
    ///   - center: The notification center managing notifications for the app.
    ///   - notification: The notification being presented.
    ///
    /// - Returns: The desired presentation options for the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
}
