//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareInboxItem: Codable {
    public let id: String
    public private(set) var notification: NotificareNotification
    public let time: Date
    public private(set) var opened: Bool
    internal let visible: Bool
    public let expires: Date?

    internal var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }

    public init(id: String, notification: NotificareNotification, time: Date, opened: Bool, visible: Bool, expires: Date?) {
        self.id = id
        self.notification = notification
        self.time = time
        self.opened = opened
        self.visible = visible
        self.expires = expires
    }
}

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
