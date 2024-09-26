//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificareUtilitiesKit

public struct NotificareUserInboxItem: Codable, Equatable {
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

// Identifiable: NotificareUserInboxItem
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareUserInboxItem: Identifiable {}

// JSON: NotificareUserInboxItem
extension NotificareUserInboxItem {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareUserInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareUserInboxItem.self, from: data)
    }
}
