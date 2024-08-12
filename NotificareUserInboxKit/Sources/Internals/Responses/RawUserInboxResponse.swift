//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal struct RawUserInboxResponse: Decodable, Equatable {
    internal let count: Int
    internal let unread: Int
    internal let inboxItems: [RawUserInboxItem]

    internal struct RawUserInboxItem: Equatable {
        internal let _id: String
        internal let notification: String
        internal let type: String
        internal let time: Date
        internal let title: String?
        internal let subtitle: String?
        internal let message: String
        internal let attachment: NotificareNotification.Attachment?
        @NotificareExtraEquatable internal private(set) var extra: [String: Any]
        internal let opened: Bool
        internal let expires: Date?

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

extension RawUserInboxResponse.RawUserInboxItem: Decodable {
    internal init(from decoder: Decoder) throws {
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
}
