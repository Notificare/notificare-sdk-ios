//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal struct RawUserInboxResponse: Decodable {
    let count: Int
    let unread: Int
    let inboxItems: [RawUserInboxItem]

    internal struct RawUserInboxItem: Decodable {
        let _id: String
        let notification: String
        let type: String
        let time: Date
        let title: String?
        let subtitle: String?
        let message: String
        let attachment: NotificareNotification.Attachment?
        let extra: [String: Any]
        let opened: Bool
        let expires: Date?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            _id = try container.decode(String.self, forKey: ._id)
            notification = try container.decode(String.self, forKey: .notification)
            type = try container.decode(String.self, forKey: .type)
            time = try container.decode(Date.self, forKey: .time)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
            message = try container.decode(String.self, forKey: .message)
            attachment = try container.decodeIfPresent(NotificareNotification.Attachment.self, forKey: .attachment)
            extra = try container.decodeIfPresent([String: Any].self, forKey: .extra) ?? [:]
            opened = try container.decodeIfPresent(Bool.self, forKey: .opened) ?? false
            expires = try container.decodeIfPresent(Date.self, forKey: .expires)
        }

        private enum CodingKeys: String, CodingKey {
            case _id
            case notification
            case type
            case time
            case title
            case subtitle
            case message
            case attachment
            case extra
            case opened
            case expires
        }

        internal func toModel() -> NotificareUserInboxItem {
            NotificareUserInboxItem(
                id: _id,
                notification: NotificareNotification(
                    partial: true,
                    id: notification,
                    type: type,
                    time: time,
                    title: title,
                    subtitle: subtitle,
                    message: message,
                    content: [],
                    actions: [],
                    attachments: attachment.map { [$0] } ?? [],
                    extra: extra,
                    targetContentIdentifier: nil
                ),
                time: time,
                opened: opened,
                expires: expires
            )
        }
    }
}
