//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit

public struct NotificareInboxItem {
    public let id: String
    public private(set) var notification: NotificareNotification
    public let time: Date
    public private(set) var opened: Bool
    internal let visible: Bool
    public let expires: Date?

    internal var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }
}

// NotificareInboxItem.init(remote:)
extension NotificareInboxItem {
    init(remote: PushAPI.Models.RemoteInboxItem) {
        let attachments: [NotificareNotification.Attachment]
        if let attachment = remote.attachment {
            attachments = [attachment]
        } else {
            attachments = []
        }

        id = remote._id
        notification = NotificareNotification(
            partial: true,
            id: remote._id,
            type: remote.type,
            time: remote.time,
            title: remote.title,
            subtitle: remote.subtitle,
            message: remote.message,
            content: [],
            actions: [],
            attachments: attachments,
            extra: remote.extra,
            targetContentIdentifier: nil
        )
        time = remote.time
        opened = remote.opened
        visible = remote.visible
        expires = remote.expires
    }
}
