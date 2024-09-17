//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit

public struct NotificareSystemNotification: Codable, Equatable {
    public let id: String
    public let type: String
    @NotificareExtraEquatable public private(set) var extra: [String: Any]

    public init(id: String, type: String, extra: [String: Any]) {
        self.id = id
        self.type = type
        self.extra = extra
    }

    internal init(userInfo: [AnyHashable: Any]) {
        id = userInfo["id"] as! String
        type = userInfo["systemType"] as! String

        let stringKeyedUserInfo = userInfo.filter { $0.key is String } as! [String: Any]
        let ignoreKeys = ["aps", "system", "systemType", "attachment", "notificationId", "notificationType", "id"]

        extra = stringKeyedUserInfo.filter { !ignoreKeys.contains($0.key) && !$0.key.hasPrefix("x-") }
    }
}

// Identifiable: NotificareSystemNotification
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareSystemNotification: Identifiable {}

// JSON: NotificareSystemNotification
extension NotificareSystemNotification {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareSystemNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareSystemNotification.self, from: data)
    }
}

// Codable: NotificareSystemNotification
extension NotificareSystemNotification {
    internal enum CodingKeys: String, CodingKey {
        case id
        case type
        case extra
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)

        let decodedExtra = try container.decode(NotificareAnyCodable.self, forKey: .extra)
        extra = decodedExtra.value as! [String: Any]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(NotificareAnyCodable(extra), forKey: .extra)
    }
}
