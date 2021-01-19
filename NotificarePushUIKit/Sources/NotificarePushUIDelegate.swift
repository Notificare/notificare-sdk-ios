//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificarePushKit

public protocol NotificarePushUIDelegate: AnyObject {
    func notificare(_ notificarePushUI: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error: Error?)

    func notificare(_ notificarePushUI: NotificarePushUI, shouldPerformSelectorWithURL url: URL, in action: NotificareNotification.Action, for notification: NotificareNotification)
}

public extension NotificarePushUIDelegate {
    func notificare(_: NotificarePushUI, willExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    func notificare(_: NotificarePushUI, didExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    func notificare(_: NotificarePushUI, didNotExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    func notificare(_: NotificarePushUI, didFailToExecuteAction _: NotificareNotification.Action, for _: NotificareNotification, error _: Error) {}

    func notificare(_: NotificarePushUI, shouldPerformSelectorWithURL _: URL, in _: NotificareNotification.Action, for _: NotificareNotification) {}
}
