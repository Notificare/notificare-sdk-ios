//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Combine
import Foundation
import NotificareKit

public protocol NotificareInbox: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles inbox events
    ///
    /// This property allows setting a delegate conforming to ``NotificareInboxDelegate`` to respond to various inbox events, such as
    /// inbox and badges updates.
    var delegate: NotificareInboxDelegate? { get set }

    /// A list of all ``NotificareInboxItem``, sorted by timestamp.
    var items: [NotificareInboxItem] { get }

    /// A Publisher for observing changes to inbox items, suitable for real-time UI updates to reflect inbox state changes.
    var itemsStream: AnyPublisher<[NotificareInboxItem], Never> { get }

    /// The current badge count, representing the number of unread inbox items.
    var badge: Int { get }

    /// A Publisher for observing changes to the badge count, providing real-time updates when the unread count changes.
    var badgeStream: AnyPublisher<Int, Never> { get }

    // MARK: Methods

    /// Refreshes the inbox data, ensuring the items and badge count reflect the latest server state.
    func refresh()

    /// Refreshes the current badge count to match the number of unread inbox items, with a callback.
    /// 
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the badge refresh operation
    func refreshBadge(_ completion: @escaping NotificareCallback<Int>)

    /// Refreshes the current badge count to match the number of unread inbox items.
    ///
    /// - Returns: The updated number of unread messages.
    func refreshBadge() async throws -> Int

    /// Opens a specified inbox item, marking it as read and returning the associated notification, with a callback.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to open.
    ///   - completion: A callback that will be invoked with the result ot the notification open operation.
    func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>)

    /// Opens a specified inbox item, marking it as read and returning the associated notification.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to open.
    ///
    /// - Returns: The ``NotificareNotification`` associated with the inbox item.
    func open(_ item: NotificareInboxItem) async throws -> NotificareNotification

    /// Marks the specified inbox item as read, with a callback.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to mark as read.
    ///   - completion: A callback that will be invoked with the result of the mark as read operation.
    func markAsRead(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    /// Marks the specified inbox item as read.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to mark as read.
    func markAsRead(_ item: NotificareInboxItem) async throws

    /// Marks all inbox items as read, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the mark all as read operation.
    func markAllAsRead(_ completion: @escaping NotificareCallback<Void>)

    /// Marks all inbox items as read.
    func markAllAsRead() async throws

    /// Permanently removes the specified inbox item from the inbox, with a callback.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to remove.
    ///   - completion: A callback that will be invoked with the result of the remove operation.
    func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>)

    /// Permanently removes the specified inbox item from the inbox.
    /// 
    /// - Parameters:
    ///   - item: The ``NotificareInboxItem`` to remove.
    func remove(_ item: NotificareInboxItem) async throws

    /// Clears all inbox items, permanently deleting them from the inbox., with a callback
    /// 
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the clear operation.
    func clear(_ completion: @escaping NotificareCallback<Void>)

    /// Clears all inbox items, permanently deleting them from the inbox.
    func clear() async throws
}
