//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareInboxDelegate: AnyObject {
    func notificare(_ notificareInbox: NotificareInbox, didLoadInbox inbox: [NotificareInboxItem])

    func notificare(_ notificareInbox: NotificareInbox, didUpdateBadge badge: Int)
}

public extension NotificareInboxDelegate {
    func notificare(_: NotificareInbox, didLoadInbox _: [NotificareInboxItem]) {}

    func notificare(_: NotificareInbox, didUpdateBadge _: Int) {}
}
