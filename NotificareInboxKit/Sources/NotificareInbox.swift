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

    @available(iOS 13.0, *)
    func refreshBadge() async throws -> Int

    func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>)

    @available(iOS 13.0, *)
    func open(_ item: NotificareInboxItem) async throws -> NotificareNotification

    func markAsRead(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func markAsRead(_ item: NotificareInboxItem) async throws

    func markAllAsRead(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func markAllAsRead() async throws

    func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func remove(_ item: NotificareInboxItem) async throws

    func clear(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func clear() async throws
}
