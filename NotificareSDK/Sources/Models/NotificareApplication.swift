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
//    public let actionCategories: [ActionCategory]

    public struct InboxConfig: Codable {
        let useInbox: Bool
        let autoBadge: Bool
    }

    public struct RegionConfig: Codable {
        public let proximityUUID: String?
    }

    public struct UserDataField: Codable {
        let type: String
        let key: String
        let label: String
    }

//    public struct ActionCategory: Codable {
//        let name: String
//        let description: String?
//        let type: NotificareNotificationType
//        let actions: [Action]
//
//        struct Action: Codable {
//            let type: NotificationAction
//            let label: String?
//            let target: String?
//            let camera: Bool
//            let keyboard: Bool
//            let destructive: Bool
//        }
//    }
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
//        case actionCategories
    }
}
