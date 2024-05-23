//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UserNotifications

public protocol NotificarePushDelegate: AnyObject {
    func notificare(_ notificarePush: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error)

    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings allowedUI: Bool)

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any])

    @available(*, deprecated, message: "Use notificare(_:didReceiveNotification:deliveryMechanism:) instead.")
    func notificare(_ notificarePush: NotificarePush, didReceiveNotification notification: NotificareNotification)

    func notificare(_ notificarePush: NotificarePush, didReceiveNotification notification: NotificareNotification, deliveryMechanism: NotificareNotificationDeliveryMechanism)

    func notificare(_ notificarePush: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification)

    func notificare(_ notificarePush: NotificarePush, shouldOpenSettings notification: NotificareNotification?)

    @available(*, deprecated, renamed: "notificare(_:didOpenUnknownAction:for:responseText:)")
    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownAction action: String, for notification: [AnyHashable: Any], responseText: String?)

    func notificare(_ notificarePush: NotificarePush, didOpenNotification notification: NotificareNotification)

    func notificare(_ notificarePush: NotificarePush, didOpenUnknownNotification userInfo: [AnyHashable: Any])

    func notificare(_ notificarePush: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePush: NotificarePush, didOpenUnknownAction action: String, for notification: [AnyHashable: Any], responseText: String?)
}

extension NotificarePushDelegate {
    public func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    public func notificare(_: NotificarePush, didChangeNotificationSettings _: Bool) {}

    public func notificare(_: NotificarePush, didReceiveUnknownNotification _: [AnyHashable: Any]) {}

    public func notificare(_: NotificarePush, didReceiveNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePush, didReceiveNotification _: NotificareNotification, deliveryMechanism _: NotificareNotificationDeliveryMechanism) {}

    public func notificare(_: NotificarePush, didReceiveSystemNotification _: NotificareSystemNotification) {}

    public func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {}

    public func notificare(_: NotificarePush, didReceiveUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {}

    public func notificare(_: NotificarePush, didOpenNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePush, didOpenUnknownNotification _: [AnyHashable: Any]) {}

    public func notificare(_: NotificarePush, didOpenAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    public func notificare(_: NotificarePush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {}
}
