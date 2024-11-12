//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UserNotifications

public protocol NotificarePushDelegate: AnyObject {
    /// Called when the app encounters an error during the registration process for remote notifications.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - error: An ``Error`` object describing the reason for the registration failure.
    func notificare(_ notificarePush: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error)

    /// Called when the device's push subscription changes.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - subscription: The updated ``NotificarePushSubscription``, or `null` if the subscription token is unavailable.
    func notificare(_ notificarePush: NotificarePush, didChangeSubscription subscription: NotificarePushSubscription?)

    /// Called when the notification settings are changed.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - allowedUI: A Boolean indicating whether the app is permitted to display notifications. `true` if notifications are allowed, `false` if they are restricted by the user.
    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings allowedUI: Bool)

    /// Called when an unknown type of notification is received.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - userInfo: A dictionary containing the payload data of the unknown notification.
    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any])

    /// Called when a push notification is received.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - notification: The received `NotificareNotification`` object.
    ///   - deliveryMechanism: The mechanism used to deliver the notification.
    func notificare(_ notificarePush: NotificarePush, didReceiveNotification notification: NotificareNotification, deliveryMechanism: NotificareNotificationDeliveryMechanism)

    /// Called when a system notification is received.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - notification: The received ``NotificareSystemNotification``.
    func notificare(_ notificarePush: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification)

    /// Called when a notification prompts the app to open its settings screen.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - notification: The received ``NotificareSystemNotification``.
    func notificare(_ notificarePush: NotificarePush, shouldOpenSettings notification: NotificareNotification?)

    /// Called when a push notification is opened by the user.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - notification: The ``NotificareNotification`` that was opened.
    func notificare(_ notificarePush: NotificarePush, didOpenNotification notification: NotificareNotification)

    /// Called when an unknown push notification is opened by the user.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - userInfo: A dictionary containing the payload data of the unknown notification.
    func notificare(_ notificarePush: NotificarePush, didOpenUnknownNotification userInfo: [AnyHashable: Any])

    /// Called when a push notification action is opened by the user.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - action: The specific action opened by the user.
    ///   - notification: The [NotificareNotification] containing the action.
    func notificare(_ notificarePush: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification)

    /// Called when an unknown push notification action is opened by the user.
    /// - Parameters:
    ///   - notificarePush: The NotificarePush object instance.
    ///   - action: The specific action opened by the user.
    ///   - notification: A dictionary containing the payload data of the unknown notification.
    ///   - responseText: A string representing the action response, if not one of the defaults.
    func notificare(_ notificarePush: NotificarePush, didOpenUnknownAction action: String, for notification: [AnyHashable: Any], responseText: String?)
}

extension NotificarePushDelegate {
    public func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    public func notificare(_: NotificarePush, didChangeSubscription _: NotificarePushSubscription?) {}

    public func notificare(_: NotificarePush, didChangeNotificationSettings _: Bool) {}

    public func notificare(_: NotificarePush, didReceiveUnknownNotification _: [AnyHashable: Any]) {}

    public func notificare(_: NotificarePush, didReceiveNotification _: NotificareNotification, deliveryMechanism _: NotificareNotificationDeliveryMechanism) {}

    public func notificare(_: NotificarePush, didReceiveSystemNotification _: NotificareSystemNotification) {}

    public func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {}

    public func notificare(_: NotificarePush, didOpenNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePush, didOpenUnknownNotification _: [AnyHashable: Any]) {}

    public func notificare(_: NotificarePush, didOpenAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    public func notificare(_: NotificarePush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {}
}
