//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

public typealias NotificareEventData = [String: Any]

public struct NotificareEvent: Equatable {
    public let type: String
    public let timestamp: Int64
    public let deviceId: String
    public let sessionId: String?
    public let notificationId: String?
    public let userId: String?
    @NotificareExtraEquatable public private(set) var data: NotificareEventData?
}

// MARK: - Codable

extension NotificareEvent: Codable {
    internal enum CodingKeys: String, CodingKey {
        case type
        case timestamp
        case deviceId = "deviceID"
        case sessionId = "sessionID"
        case notificationId = "notification"
        case userId = "userID"
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(String.self, forKey: .type)
        timestamp = try container.decode(Int64.self, forKey: .timestamp)
        deviceId = try container.decode(String.self, forKey: .deviceId)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
        notificationId = try container.decodeIfPresent(String.self, forKey: .notificationId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)

        if let data = try container.decodeIfPresent(NotificareAnyCodable.self, forKey: .data) {
            self.data = data.value as? NotificareEventData
        } else {
            data = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encodeIfPresent(sessionId, forKey: .sessionId)
        try container.encodeIfPresent(notificationId, forKey: .notificationId)
        try container.encodeIfPresent(userId, forKey: .userId)

        if let data = data {
            try container.encode(NotificareAnyCodable(data), forKey: .data)
        }
    }
}
