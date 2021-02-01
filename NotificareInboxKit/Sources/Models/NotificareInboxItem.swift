//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore

public struct NotificareInboxItem {
    public let id: String
    public let notificationId: String
    public let type: String
    public let time: Date
    public let title: String?
    public let subtitle: String?
    public let message: String
    public let attachment: Attachment?
    public let extra: [String: Any]
    public let opened: Bool
    internal let visible: Bool
    public let expires: Date?

    internal var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }
}

// NotificareInboxItem.init(userInfo)
extension NotificareInboxItem {
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

        let ignoreKeys = ["aps", "alert", "inboxItemId", "inboxItemVisible", "inboxItemExpires", "system", "systemType", "attachment", "notificationId", "notificationType", "id", "x-sender"]
        extra = userInfo
            .filter { $0.key is String }
            .mapKeys { $0 as! String }
            .filter { !ignoreKeys.contains($0.key) }

        opened = false
        visible = userInfo["inboxItemVisible"] as? Bool ?? false

        if let expiresStr = userInfo["inboxItemExpires"] as? String {
            expires = NotificareUtils.isoDateFormatter.date(from: expiresStr)
        } else {
            expires = nil
        }
    }
}

extension NotificareInboxItem: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        notificationId = try container.decode(String.self, forKey: .notificationId)
        type = try container.decode(String.self, forKey: .type)
        time = try container.decode(Date.self, forKey: .time)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        message = try container.decode(String.self, forKey: .message)
        attachment = try container.decodeIfPresent(Attachment.self, forKey: .attachment)
        extra = try container.decodeIfPresent([String: Any].self, forKey: .extra) ?? [:]
        opened = try container.decode(Bool.self, forKey: .opened)
        visible = try container.decode(Bool.self, forKey: .visible)
        expires = try container.decodeIfPresent(Date.self, forKey: .expires)
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case notificationId = "notification"
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

// NotificareInboxItem.Attachment
public extension NotificareInboxItem {
    struct Attachment: Codable {
        public let mimeType: String
        public let uri: String
    }
}
