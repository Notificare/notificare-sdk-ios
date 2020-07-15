//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareApplicationInfo: Codable {
    public let id: String
    public let name: String
    public let category: String
    public let appStoreId: String?
    public let androidPackageName: String?
    public let services: Services
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

    public struct Services: Codable {
        let richPush: Bool
        let locationServices: Bool
        let apns: Bool
        let gcm: Bool
        let hms: Bool
        let websockets: Bool
        let triggers: Bool
        let passbook: Bool
        let inAppPurchase: Bool
        let oauth2: Bool
        let screens: Bool
        let reports: Bool
        let appsOnDemand: Bool
        let liveApi: Bool
        let automation: Bool
        let websitePush: Bool
        let inbox: Bool
        let storage: Bool
        let email: Bool
        let sms: Bool
    }

    public struct InboxConfig: Codable {
        let useInbox: Bool
        let autoBadge: Bool
    }

    public struct PassbookConfig: Codable {

    }

    public struct RegionConfig: Codable {

    }

    public struct WebsitePushConfig: Codable {

    }

    public struct UserDataField: Codable {
        let type: NotificareUserDataFieldType
        let key: String
        let label: String
        let defaultValue: String?

        enum CodingKeys: String, CodingKey {
            case type
            case key
            case label
            case defaultValue
        }
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
