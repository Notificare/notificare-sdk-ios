//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public protocol NotificarePushUIDelegate: AnyObject {
    // MARK: - Notifications

    func notificare(_ notificarePushUI: NotificarePushUI, willPresentNotification notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didPresentNotification notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification)

    // MARK: - Actions

    func notificare(_ notificarePushUI: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    func notificare(_ notificarePushUI: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error: Error?)

    func notificare(_ notificarePushUI: NotificarePushUI, didReceiveCustomAction url: URL, in action: NotificareNotification.Action, for notification: NotificareNotification)
}

extension NotificarePushUIDelegate {
    public func notificare(_: NotificarePushUI, willPresentNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didPresentNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didFinishPresentingNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didFailToPresentNotification _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didClickURL _: URL, in _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, willExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didNotExecuteAction _: NotificareNotification.Action, for _: NotificareNotification) {}

    public func notificare(_: NotificarePushUI, didFailToExecuteAction _: NotificareNotification.Action, for _: NotificareNotification, error _: Error?) {}

    public func notificare(_: NotificarePushUI, didReceiveCustomAction _: URL, in _: NotificareNotification.Action, for _: NotificareNotification) {}
}
