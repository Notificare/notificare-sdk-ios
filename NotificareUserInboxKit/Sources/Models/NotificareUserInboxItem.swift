//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUserInboxItem: Codable {
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

// JSON: NotificareUserInboxItem
public extension NotificareUserInboxItem {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareUserInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUserInboxItem.self, from: data)
    }
}
