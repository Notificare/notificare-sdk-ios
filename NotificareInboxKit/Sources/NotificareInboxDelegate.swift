//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInboxDelegate: AnyObject {
    func notificare(_ notificareInbox: NotificareInbox, didUpdateInbox items: [NotificareInboxItem])

    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int)
}

extension NotificareInboxDelegate {
    public func notificare(_: NotificareInbox, didUpdateInbox _: [NotificareInboxItem]) {}

    public func notificare(_: NotificareInbox, didUpdateBadge _: Int) {}
}
