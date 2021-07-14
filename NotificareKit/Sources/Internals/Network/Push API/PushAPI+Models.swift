//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public extension NotificareInternals.PushAPI.Models {
    struct Application: Decodable {
        public let _id: String
        public let name: String
        public let category: String
        public let appStoreId: String?
        public let services: [String: Bool]
        public let inboxConfig: NotificareApplication.InboxConfig?
        public let regionConfig: NotificareApplication.RegionConfig?
        public let userDataFields: [NotificareApplication.UserDataField]
        public let actionCategories: [NotificareApplication.ActionCategory]

        public func toModel() -> NotificareApplication {
            NotificareApplication(
                id: _id,
                name: name,
                category: category,
                appStoreId: appStoreId,
                services: services,
                inboxConfig: inboxConfig,
                regionConfig: regionConfig,
                userDataFields: userDataFields,
                actionCategories: actionCategories
            )
        }
    }

    struct Notification: Decodable {
        public let _id: String
        public let type: String
        public let time: Date
        public let title: String?
        public let subtitle: String?
        public let message: String
        public let content: [NotificareNotification.Content]
        public let actions: [NotificareNotification.Action]
        public let attachments: [NotificareNotification.Attachment]
        public let extra: [String: Any]
        public let targetContentIdentifier: String?

        enum CodingKeys: String, CodingKey {
            case _id
            case type
            case time
            case title
            case subtitle
            case message
            case content
            case actions
            case attachments
            case extra
            case targetContentIdentifier
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            _id = try container.decode(String.self, forKey: ._id)
            type = try container.decode(String.self, forKey: .type)
            time = try container.decode(Date.self, forKey: .time)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
            message = try container.decode(String.self, forKey: .message)

            if container.contains(.content) {
                content = try container.decode([NotificareNotification.Content].self, forKey: .content)
            } else {
                content = []
            }

            if container.contains(.actions) {
                actions = try container.decode([NotificareNotification.Action].self, forKey: .actions)
            } else {
                actions = []
            }

            if container.contains(.attachments) {
                attachments = try container.decode([NotificareNotification.Attachment].self, forKey: .attachments)
            } else {
                attachments = []
            }

            if container.contains(.extra) {
                let decoded = try container.decode(AnyCodable.self, forKey: .extra)
                extra = decoded.value as! [String: Any]
            } else {
                extra = [:]
            }

            targetContentIdentifier = try container.decodeIfPresent(String.self, forKey: .targetContentIdentifier)
        }

        public func toModel() -> NotificareNotification {
            NotificareNotification(
                partial: false,
                id: _id,
                type: type,
                time: time,
                title: title,
                subtitle: subtitle,
                message: message,
                content: content,
                actions: actions,
                attachments: attachments,
                extra: extra,
                targetContentIdentifier: targetContentIdentifier
            )
        }
    }
}
