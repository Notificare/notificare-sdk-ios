//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareInboxItem: Codable {
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
public extension NotificareInboxItem {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareInboxItem.self, from: data)
    }
}
