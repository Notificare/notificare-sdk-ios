//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareUserInbox: AnyObject {
    /// Parses a JSON string to produce a ``NotificareUserInboxResponse``.
    ///
    /// This method takes a raw JSON string and converts it into a structured ``NotificareUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - string: The JSON string representing the user inbox response.
    /// - Returns: A ``NotificareUserInboxResponse`` object parsed from the provided JSON string.
    func parseResponse(string: String) throws -> NotificareUserInboxResponse

    /// Parses a dictionary to produce a ``NotificareUserInboxResponse``.
    ///
    /// This method takes a dictionary and converts it into a structured ``NotificareUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - json: The dictionary representing the user inbox response.
    /// - Returns: A ``NotificareUserInboxResponse`` object parsed from the provided string.
    func parseResponse(json: [String: Any]) throws -> NotificareUserInboxResponse

    /// Parses a ``Data`` object to produce a ``NotificareUserInboxResponse``.
    ///
    /// This method takes a ``Data`` object and converts it into a structured ``NotificareUserInboxResponse``.
    ///
    /// - Parameters:
    ///   - data: The ``Data`` object representing the user inbox response.
    /// - Returns: A ``NotificareUserInboxResponse`` object parsed from the provided ``Data`` object.
    func parseResponse(data: Data) throws -> NotificareUserInboxResponse

    /// Opens a specified inbox item and retrieves its associated notification, with a callback.
    ///
    /// This is a suspending function that opens the provided ``NotificareUserInboxItem`` and returns the
    /// associated ``NotificareNotification`` via callback. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``NotificareUserInboxItem`` to open.
    ///   - completion: A callback that will be invoked with the result ot the notification open operation.
    func open(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>)

    /// Opens a specified inbox item and retrieves its associated notification.
    ///
    /// This is a suspending function that opens the provided ``NotificareUserInboxItem`` and returns the
    /// associated ``NotificareNotification``. This operation marks the item as read.
    ///
    /// - Parameters:
    ///   - item: The ``NotificareUserInboxItem`` to open.
    /// - Returns: The ``NotificareNotification`` associated with the opened inbox item.
    func open(_ item: NotificareUserInboxItem) async throws -> NotificareNotification

    /// Marks an inbox item as read, with a callback.
    ///
    /// This function updates the status of the provided ``NotificareUserInboxItem`` to read.
    /// - Parameters:
    ///   - item: The ``NotificareUserInboxItem`` to mark as read.
    ///   - completion: A callback that will be inboked with the result of the mark as read operation.
    func markAsRead(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>)

    /// Marks an inbox item as read.
    ///
    /// This function updates the status of the provided ``NotificareUserInboxItem`` to read.
    ///
    /// - Parameters:
    ///   - item: The ``NotificareUserInboxItem`` to mark as read.
    func markAsRead(_ item: NotificareUserInboxItem) async throws

    /// Removes an inbox item from the user's inbox, with a callback.
    ///
    /// This method deletes the provided ``NotificareUserInboxItem`` from the user's inbox.
    /// - Parameters:
    ///   - item: The ``NotificareUserInboxItem`` to be removed.
    ///   - completion: A callback that will be invoked with the result of the remove operation.
    func remove(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>)

    /// Removes an inbox item from the user's inbox.
    ///
    /// This method deletes the provided ``NotificareUserInboxItem`` from the user's inbox.
    ///
    /// - Parameter item: The ``NotificareUserInboxItem`` to be removed.
    func remove(_ item: NotificareUserInboxItem) async throws
}
