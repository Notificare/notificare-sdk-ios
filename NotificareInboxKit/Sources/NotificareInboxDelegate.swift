//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInboxDelegate: AnyObject {
    /// Called when the inbox is successfully updated.
    ///
    /// - Parameters:
    ///   - notificareInbox: The NotificareInbox object instance.
    ///   - items: The updated list of ``NotificareInboxItem``
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem])

    /// Called when the unread message count badge is updated.
    ///
    /// - Parameters:
    ///   - notificareInbox: The NotificareInbox object instance.
    ///   - badge: The updated unread messages count.
    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int)
}

extension NotificareInboxDelegate {
    public func notificare(_: NotificareInbox, didUpdateInbox _: [NotificareInboxItem]) {}

    public func notificare(_: NotificareInbox, didUpdateBadge _: Int) {}
}
