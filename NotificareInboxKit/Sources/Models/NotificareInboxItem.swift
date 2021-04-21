//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareInboxItem: Codable {
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

// NotificareInboxItem JSON
public extension NotificareInboxItem {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareInboxItem {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareInboxItem.self, from: data)
    }
}
