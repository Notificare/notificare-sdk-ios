//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public protocol NotificarePushUIDelegate: AnyObject {
    // MARK: - Notifications

    /// Called when a notification is about to be presented.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - notification: The ``NotificareNotification`` that will be presented.
    func notificare(_ notificarePushUI: NotificarePushUI, willPresentNotification notification: NotificareNotification)

    /// Called when a notification has been presented.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - notification: The ``NotificareNotification`` that was presented.
    func notificare(_ notificarePushUI: NotificarePushUI, didPresentNotification notification: NotificareNotification)

    /// Called when the presentation of a notification has finished.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - notification: The ``NotificareNotification`` that finished presenting.
    func notificare(_ notificarePushUI: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification)

    /// Called when a notification fails to present.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - notification: The ``NotificareNotification` that failed to present.
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification)

    /// Called when a URL within a notification is clicked.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - url: The clicked URL.
    ///   - notification: The ``NotificareNotification`` containing the clicked URL.
    func notificare(_ notificarePushUI: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification)

    // MARK: - Actions

    /// Called when an action associated with a notification is about to execute.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - action: The ``NotificareNotification.Action`` that will be executed.
    ///   - notification: The ``NotificareNotification`` containing the action.
    func notificare(_ notificarePushUI: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    /// Called when an action associated with a notification has been executed.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - action: The ``NotificareNotification.Action`` that was executed.
    ///   - notification: The ``NotificareNotification` containing the action.
    func notificare(_ notificarePushUI: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    /// Called when an action associated with a notification has not executed.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - action: The ``NotificareNotification.Action`` that was not executed.
    ///   - notification: The ``NotificareNotification`` containing the action.
    func notificare(_ notificarePushUI: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification)

    /// Called when an action associated with a notification fails to execute.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - action: The ``NotificareNotification.Action` that failed to execute.
    ///   - notification: The ``NotificareNotification`` containing the action.
    ///   - error: The ``Error`` associated with the failure (optional).
    func notificare(_ notificarePushUI: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error: Error?)

    /// Called when a custom action associated with a notification is received.
    /// - Parameters:
    ///   - notificarePushUI: The NotificarePushUI object instance.
    ///   - url: The URL representing the custom action.
    ///   - action: The ``NotificareNotification.Action`` that triggered the custom action.
    ///   - notification: The `NotificareNotification`` containing the custom action.
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
