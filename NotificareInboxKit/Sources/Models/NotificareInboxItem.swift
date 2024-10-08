//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit

public struct NotificareInboxItem: Codable, Equatable {
    public let id: String
    public let notification: NotificareNotification
    public let time: Date
    public let opened: Bool
    public let expires: Date?

    public init(id: String, notification: NotificareNotification, time: Date, opened: Bool, expires: Date?) {
        self.id = id
        self.notification = notification
        self.time = time
        self.opened = opened
        self.expires = expires
    }
}

// Identifiable: NotificareInboxItem
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareInboxItem: Identifiable {}

// JSON: NotificareInboxItem
extension NotificareInboxItem {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.notificare.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.notificare.decode(NotificareInboxItem.self, from: data)
    }
}
