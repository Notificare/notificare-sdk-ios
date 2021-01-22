//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore

public struct NotificareInboxItem {
    public let id: String
    public let notificationId: String
    public let type: String // TODO: this is nullable on v2
    public let time: Date
    public let title: String?
    public let subtitle: String?
    public let message: String
    public let attachment: Attachment?
    public let extras: [AnyHashable: Any]
    public let opened: Bool
    public let visible: Bool
    public let expires: Date?

    init?(userInfo: [AnyHashable: Any]) {
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any] ?? userInfo["alert"] as? [String: Any]

        guard let id = userInfo["inboxItemId"] as? String,
              let type = userInfo["notificationType"] as? String,
              let notificationId = userInfo["notificationId"] as? String,
              let message = alert?["body"] as? String
        else {
            return nil
        }

        self.id = id
        self.notificationId = notificationId
        self.type = type
        time = Date()
        title = alert?["title"] as? String
        subtitle = alert?["subtitle"] as? String
        self.message = message

        if let attachment = userInfo["attachment"] as? [String: Any],
           let mimeType = attachment["mimeType"] as? String,
           let uri = attachment["uri"] as? String
        {
            self.attachment = Attachment(mimeType: mimeType, uri: uri)
        } else {
            attachment = nil
        }

        let ignoreKeys = ["aps", "system", "systemType", "attachment", "notificationId", "id", "x-sender"]
        extras = userInfo.filter { (entry) -> Bool in
            let key = entry.key as? String ?? ""
            return !ignoreKeys.contains(key)
        }

        opened = false
        visible = userInfo["inboxItemVisible"] as? Bool ?? false

        if let expiresStr = userInfo["inboxItemExpires"] as? String {
            expires = NotificareUtils.isoDateFormatter.date(from: expiresStr)
        } else {
            expires = nil
        }
    }
}

// NotificareInboxItem.Attachment
public extension NotificareInboxItem {
    struct Attachment {
        public let mimeType: String
        public let uri: String
    }
}
