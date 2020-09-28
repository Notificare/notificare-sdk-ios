//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareApplicationInfo: Codable {
    public let id: String
    public let name: String
    public let category: String
    public let appStoreId: String?
    public let androidPackageName: String?
    public let services: [String: Bool]
    public let inboxConfig: InboxConfig?
    public let passbookConfig: PassbookConfig?
    public let regionConfig: RegionConfig?
    public let websitePushConfig: WebsitePushConfig?
    public let userDataFields: [UserDataField]
    public let actionCategories: [ActionCategory]

    // MARK: Coding keys

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case category
        case appStoreId
        case androidPackageName
        case services
        case inboxConfig
        case passbookConfig
        case regionConfig
        case websitePushConfig
        case userDataFields
        case actionCategories
    }

    // MARK: Nested models

    public struct InboxConfig: Codable {
        let useInbox: Bool
        let autoBadge: Bool
    }

    public struct PassbookConfig: Codable {}

    public struct RegionConfig: Codable {}

    public struct WebsitePushConfig: Codable {}

    public struct UserDataField: Codable {
        let type: NotificareUserDataFieldType
        let key: String
        let label: String
        let defaultValue: String?
    }

    public struct ActionCategory: Codable {
        let name: String
        let description: String?
        let type: NotificareNotificationType
        let actions: [Action]

        struct Action: Codable {
            let type: NotificationAction
            let label: String?
            let target: String?
            let camera: Bool
            let keyboard: Bool
            let destructive: Bool
        }
    }
}
