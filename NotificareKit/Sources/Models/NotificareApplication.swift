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

    public init(id: String, name: String, category: String, appStoreId: String?, services: [String: Bool], inboxConfig: NotificareApplication.InboxConfig?, regionConfig: NotificareApplication.RegionConfig?, userDataFields: [NotificareApplication.UserDataField], actionCategories: [NotificareApplication.ActionCategory]) {
        self.id = id
        self.name = name
        self.category = category
        self.appStoreId = appStoreId
        self.services = services
        self.inboxConfig = inboxConfig
        self.regionConfig = regionConfig
        self.userDataFields = userDataFields
        self.actionCategories = actionCategories
    }

    public enum ServiceKey: String {
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

    public struct InboxConfig: Codable {
        public let useInbox: Bool
        public let autoBadge: Bool

        public init(useInbox: Bool, autoBadge: Bool) {
            self.useInbox = useInbox
            self.autoBadge = autoBadge
        }
    }

    public struct RegionConfig: Codable {
        public let proximityUUID: String?

        public init(proximityUUID: String?) {
            self.proximityUUID = proximityUUID
        }
    }

    public struct UserDataField: Codable {
        public let type: String
        public let key: String
        public let label: String

        public init(type: String, key: String, label: String) {
            self.type = type
            self.key = key
            self.label = label
        }
    }

    public struct ActionCategory: Codable {
        public let name: String
        public let description: String?
        public let type: String
        public let actions: [NotificareNotification.Action]

        public init(name: String, description: String?, type: String, actions: [NotificareNotification.Action]) {
            self.name = name
            self.description = description
            self.type = type
            self.actions = actions
        }
    }
}

// JSON: NotificareApplication
public extension NotificareApplication {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareApplication {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.self, from: data)
    }
}

// JSON: NotificareApplication.InboxConfig
public extension NotificareApplication.InboxConfig {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareApplication.InboxConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.InboxConfig.self, from: data)
    }
}

// JSON: NotificareApplication.RegionConfig
public extension NotificareApplication.RegionConfig {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareApplication.RegionConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.RegionConfig.self, from: data)
    }
}

// JSON: NotificareApplication.UserDataField
public extension NotificareApplication.UserDataField {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareApplication.UserDataField {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.UserDataField.self, from: data)
    }
}

// JSON: NotificareApplication.ActionCategory
public extension NotificareApplication.ActionCategory {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareApplication.ActionCategory {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareApplication.ActionCategory.self, from: data)
    }
}
