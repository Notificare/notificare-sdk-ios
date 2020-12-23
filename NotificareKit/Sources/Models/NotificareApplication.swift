//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

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

    public struct InboxConfig: Codable {
        public let useInbox: Bool
        public let autoBadge: Bool
    }

    public struct RegionConfig: Codable {
        public let proximityUUID: String?
    }

    public struct UserDataField: Codable {
        public let type: String
        public let key: String
        public let label: String
    }

    public struct ActionCategory: Codable {
        public let name: String
        public let description: String?
        public let type: String
        public let actions: [Action]

        public struct Action: Codable {
            public let type: String
            public let label: String
            public let target: String?
            public let camera: Bool
            public let keyboard: Bool
            public let destructive: Bool
        }
    }
}

// Coding keys
extension NotificareApplication {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case category
        case appStoreId
        case services
        case inboxConfig
        case regionConfig
        case userDataFields
        case actionCategories
    }
}
