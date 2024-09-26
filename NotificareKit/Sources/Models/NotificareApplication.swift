//
// Copyright (c) 2020 Notificare. All rights reserved.
//
import NotificareUtilitiesKit

public struct NotificareApplication: Codable, Equatable {
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

    public struct InboxConfig: Codable, Equatable {
        public let useInbox: Bool
        public let useUserInbox: Bool
        public let autoBadge: Bool

        public init(useInbox: Bool, useUserInbox: Bool, autoBadge: Bool) {
            self.useInbox = useInbox
            self.useUserInbox = useUserInbox
            self.autoBadge = autoBadge
        }
    }

    public struct RegionConfig: Codable, Equatable {
        public let proximityUUID: String?

        public init(proximityUUID: String?) {
            self.proximityUUID = proximityUUID
        }
    }

    public struct UserDataField: Codable, Equatable {
        public let type: String
        public let key: String
        public let label: String

        public init(type: String, key: String, label: String) {
            self.type = type
            self.key = key
            self.label = label
        }
    }

    public struct ActionCategory: Codable, Equatable {
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

// Identifiable: NotificareApplication
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareApplication: Identifiable {}

// JSON: NotificareApplication
extension NotificareApplication {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareApplication.self, from: data)
    }
}

// JSON: NotificareApplication.InboxConfig
extension NotificareApplication.InboxConfig {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication.InboxConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareApplication.InboxConfig.self, from: data)
    }
}

// JSON: NotificareApplication.RegionConfig
extension NotificareApplication.RegionConfig {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication.RegionConfig {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareApplication.RegionConfig.self, from: data)
    }
}

// JSON: NotificareApplication.UserDataField
extension NotificareApplication.UserDataField {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication.UserDataField {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareApplication.UserDataField.self, from: data)
    }
}

// JSON: NotificareApplication.ActionCategory
extension NotificareApplication.ActionCategory {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareApplication.ActionCategory {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareApplication.ActionCategory.self, from: data)
    }
}
