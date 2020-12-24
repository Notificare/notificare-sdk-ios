//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificarePushDelegate: AnyObject {
    func notificare(_ notificarePush: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error)

    func notificare(_ notificarePush: NotificarePush, didChangeNotificationSettings granted: Bool)

    func notificare(_ notificarePush: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any])

    func notificare(_ notificarePush: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification)
}

public extension NotificarePushDelegate {
    func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    func notificare(_: NotificarePush, didChangeNotificationSettings _: Bool) {}

    func notificare(_: NotificarePush, didReceiveUnknownNotification _: [AnyHashable: Any]) {}

    func notificare(_: NotificarePush, didReceiveSystemNotification _: NotificareSystemNotification) {}
}
