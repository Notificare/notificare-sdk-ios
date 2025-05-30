//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit

extension NotificareInternals.PushAPI.Models {
    internal struct RemoteInboxItem: Equatable {
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
        internal let visible: Bool
        internal let expires: Date?

        internal func toLocal() -> LocalInboxItem {
            LocalInboxItem(
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
                visible: visible,
                expires: expires
            )
        }
    }
}

extension NotificareInternals.PushAPI.Models.RemoteInboxItem: Decodable {
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
        if let extra = try container.decodeIfPresent(NotificareAnyCodable.self, forKey: .extra) {
            self.extra = extra.value as! [String: Any]
        } else {
            extra = [:]
        }
        opened = try container.decodeIfPresent(Bool.self, forKey: .opened) ?? false
        visible = try container.decodeIfPresent(Bool.self, forKey: .visible) ?? true
        expires = try container.decodeIfPresent(Date.self, forKey: .expires)
    }

    internal enum CodingKeys: String, CodingKey {
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
        case visible
        case expires
    }
}
