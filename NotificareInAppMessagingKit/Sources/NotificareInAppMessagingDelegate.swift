//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInAppMessagingDelegate: AnyObject {
    func notificare(_ notificare: NotificareInAppMessaging, didPresentMessage message: NotificareInAppMessage)

    func notificare(_ notificare: NotificareInAppMessaging, didFinishPresentingMessage message: NotificareInAppMessage)

    func notificare(_ notificare: NotificareInAppMessaging, didFailToPresentMessage message: NotificareInAppMessage)

    func notificare(_ notificare: NotificareInAppMessaging, didExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage)

    func notificare(_ notificare: NotificareInAppMessaging, didFailToExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage, error: Error?)
}

extension NotificareInAppMessagingDelegate {
    public func notificare(_: NotificareInAppMessaging, didPresentMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFinishPresentingMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFailToPresentMessage _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didExecuteAction _: NotificareInAppMessage.Action, for _: NotificareInAppMessage) {}

    public func notificare(_: NotificareInAppMessaging, didFailToExecuteAction _: NotificareInAppMessage.Action, for _: NotificareInAppMessage, error _: Error?) {}
}
