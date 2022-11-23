//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareUserInbox: AnyObject {
    func parseResponse(string: String) throws -> NotificareUserInboxResponse

    func parseResponse(json: [String: Any]) throws -> NotificareUserInboxResponse

    func parseResponse(data: Data) throws -> NotificareUserInboxResponse

    func open(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>)

    @available(iOS 13.0, *)
    func open(_ item: NotificareUserInboxItem) async throws -> NotificareNotification

    func markAsRead(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func markAsRead(_ item: NotificareUserInboxItem) async throws

    func remove(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func remove(_ item: NotificareUserInboxItem) async throws
}
