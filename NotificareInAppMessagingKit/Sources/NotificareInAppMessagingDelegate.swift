//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInAppMessagingDelegate: AnyObject {
    /// Called when an in-app message is successfully presented to the user.
    /// - Parameters:
    ///   - notificare: The NotificareInAppMessaging object instance.
    ///   - message: The ``NotificareInAppMessage`` that was presented.
    func notificare(_ notificare: NotificareInAppMessaging, didPresentMessage message: NotificareInAppMessage)

    /// Called when the presentation of an in-app message has finished.
    /// - Parameters:
    ///   - notificare: The NotificareInAppMessaging object instance.
    ///   - message: The ``NotificareInAppMessage` that finished presenting.
    func notificare(_ notificare: NotificareInAppMessaging, didFinishPresentingMessage message: NotificareInAppMessage)

    /// Called when an in-app message failed to present.
    /// - Parameters:
    ///   - notificare: The NotificareInAppMessaging object instance.
    ///   - message: The ``NotificareInAppMessage` that failed to be presented.
    func notificare(_ notificare: NotificareInAppMessaging, didFailToPresentMessage message: NotificareInAppMessage)

    /// Called when an action is successfully executed for an in-app message.
    /// - Parameters:
    ///   - notificare: The NotificareInAppMessaging object instance.
    ///   - action: The ``NotificareInAppMessage` for which the action was executed.
    ///   - message: The ``NotificareInAppMessage.Action`` that was executed.
    func notificare(_ notificare: NotificareInAppMessaging, didExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage)

    /// Called when an action execution failed for an in-app message.
    /// - Parameters:
    ///   - notificare: The NotificareInAppMessaging object instance.
    ///   - action: The ``NotificareInAppMessage.Action`` that failed to execute.
    ///   - message: The ``NotificareInAppMessage`` for which the action was attempted.
    ///   - error: An optional ``Error``describing the error, or `null` if no specific error was provided.
    func notificare(_ notificare: NotificareInAppMessaging, didFailToExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage, error: Error?)
}

extension NotificareInAppMessagingDelegate {
    public func notificare(_: NotificareInAppMessaging, didPresentMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFinishPresentingMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFailToPresentMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didExecuteAction _: NotificareInAppMessage.Action, for _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFailToExecuteAction _: NotificareInAppMessage.Action, for _: NotificareInAppMessage, error _: Error?) {}
}
