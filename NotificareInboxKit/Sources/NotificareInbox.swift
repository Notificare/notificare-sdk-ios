//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareInbox: AnyObject {
    // MARK: Properties

    var delegate: NotificareInboxDelegate? { get set }

    var items: [NotificareInboxItem] { get }

    var badge: Int { get }

    // MARK: Methods

    func refresh()

    func refreshBadge(_ completion: @escaping NotificareCallback<Int>)

    func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>)

    func markAsRead(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    func markAllAsRead(_ completion: @escaping NotificareCallback<Void>)

    func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    func clear(_ completion: @escaping NotificareCallback<Void>)
}
