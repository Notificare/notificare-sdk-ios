//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public struct NotificareApplication: Codable {
    public let id: String
    public let name: String
    public let category: String
    public let appStoreId: String?
    public let services: [String: Bool]
    public let inboxConfig: InboxConfig?
    public let regionConfig: RegionConfig?
    public let userDataFields: [UserDataField]
    public let actionCategories: [ActionCategory]

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.self, from: data)
    }
}

public extension NotificareApplication {
    enum ServiceKey: String {
        case oauth2
        case richPush
        case locationServices
        case apns
        case gcm
        case websockets
        case passbook
        case inAppPurchase
        case inbox
        case storage
    }
}

public extension NotificareApplication {
    struct InboxConfig: Codable {
        public let useInbox: Bool
        public let autoBadge: Bool

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> InboxConfig {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(InboxConfig.self, from: data)
        }
    }
}

public extension NotificareApplication {
    struct RegionConfig: Codable {
        public let proximityUUID: String?

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> RegionConfig {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(RegionConfig.self, from: data)
        }
    }
}

public extension NotificareApplication {
    struct UserDataField: Codable {
        public let type: String
        public let key: String
        public let label: String

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> UserDataField {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(UserDataField.self, from: data)
        }
    }
}

public extension NotificareApplication {
    struct ActionCategory: Codable {
        public let name: String
        public let description: String?
        public let type: String
        public let actions: [Action]

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> ActionCategory {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(ActionCategory.self, from: data)
        }
    }
}

public extension NotificareApplication.ActionCategory {
    struct Action: Codable {
        public let type: String
        public let label: String
        public let target: String?
        public let camera: Bool
        public let keyboard: Bool
        public let destructive: Bool
        public let icon: Icon?

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Action {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Action.self, from: data)
        }
    }
}

public extension NotificareApplication.ActionCategory.Action {
    struct Icon: Codable {
        public let android: String?
        public let ios: String?
        public let web: String?
    }
}
