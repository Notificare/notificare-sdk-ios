//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUserInboxResponse: Codable, Equatable {
    public let count: Int
    public let unread: Int
    public let items: [NotificareUserInboxItem]
}

// Codable: NotificareUserInboxResponse
extension NotificareUserInboxResponse {
    public init(from decoder: Decoder) throws {
        do {
            let raw = try RawUserInboxResponse(from: decoder)

            count = raw.count
            unread = raw.unread
            items = raw.inboxItems.map { $0.toModel() }

            return
        } catch {
            NotificareLogger.debug("Unable to parse user inbox response from the raw format.", error: error)
        }

        do {
            let consumer = try ConsumerUserInboxResponse(from: decoder)

            count = consumer.count
            unread = consumer.unread
            items = consumer.items
        } catch {
            NotificareLogger.debug("Unable to parse user inbox response from the consumer format.", error: error)
            throw error
        }
    }

    public func encode(to encoder: Encoder) throws {
        let consumer = ConsumerUserInboxResponse(count: count, unread: unread, items: items)
        try consumer.encode(to: encoder)
    }
}

// JSON: NotificareUserInboxResponse
extension NotificareUserInboxResponse {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUserInboxResponse.self, from: data)
    }
}
