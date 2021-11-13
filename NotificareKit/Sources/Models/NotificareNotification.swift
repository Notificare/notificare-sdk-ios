//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public struct NotificareNotification {
    public let partial: Bool
    public let id: String
    public let type: String
    public let time: Date
    public let title: String?
    public let subtitle: String?
    public let message: String
    public let content: [Content]
    public let actions: [Action]
    public let attachments: [Attachment]
    public let extra: [String: Any]
    public let targetContentIdentifier: String?

    public init(partial: Bool, id: String, type: String, time: Date, title: String?, subtitle: String?, message: String, content: [Content], actions: [Action], attachments: [Attachment], extra: [String: Any], targetContentIdentifier: String?) {
        self.partial = partial
        self.id = id
        self.type = type
        self.time = time
        self.title = title
        self.subtitle = subtitle
        self.message = message
        self.content = content
        self.actions = actions
        self.attachments = attachments
        self.extra = extra
        self.targetContentIdentifier = targetContentIdentifier
    }

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareNotification {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareNotification.self, from: data)
    }
}

extension NotificareNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case partial
        case id
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

        partial = try container.decodeIfPresent(Bool.self, forKey: .partial) ?? false
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        time = try container.decode(Date.self, forKey: .time)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        message = try container.decode(String.self, forKey: .message)
        content = try container.decode([Content].self, forKey: .content)
        actions = try container.decode([Action].self, forKey: .actions)
        attachments = try container.decode([Attachment].self, forKey: .attachments)

        let decodedExtra = try container.decode(AnyCodable.self, forKey: .extra)
        extra = decodedExtra.value as! [String: Any]

        targetContentIdentifier = try container.decodeIfPresent(String.self, forKey: .targetContentIdentifier)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(partial, forKey: .partial)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(time, forKey: .time)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(message, forKey: .message)
        try container.encode(content, forKey: .content)
        try container.encode(actions, forKey: .actions)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(AnyCodable(extra), forKey: .extra)
        try container.encode(targetContentIdentifier, forKey: .targetContentIdentifier)
    }
}

// NotificareNotification.NotificationType
public extension NotificareNotification {
    enum NotificationType: String {
        case none = "re.notifica.notification.None"
        case alert = "re.notifica.notification.Alert"
        case webView = "re.notifica.notification.WebView"
        case url = "re.notifica.notification.URL"
        case urlScheme = "re.notifica.notification.URLScheme"
        case image = "re.notifica.notification.Image"
        case video = "re.notifica.notification.Video"
        case map = "re.notifica.notification.Map"
        case rate = "re.notifica.notification.Rate"
        case passbook = "re.notifica.notification.Passbook"
        case store = "re.notifica.notification.Store"
    }
}

// NotificareNotification.Content
public extension NotificareNotification {
    struct Content: Codable {
        public let type: String
        public let data: Any

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)

            let decoded = try container.decode(AnyCodable.self, forKey: .data)
            data = decoded.value
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(type, forKey: .type)
            try container.encode(AnyCodable(data), forKey: .data)
        }

        enum CodingKeys: String, CodingKey {
            case type
            case data
        }

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Content {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Content.self, from: data)
        }
    }
}

// NotificareNotification.Action
public extension NotificareNotification {
    struct Action: Codable {
        public let type: String
        public let label: String
        public let target: String?
        public let keyboard: Bool
        public let camera: Bool

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Action {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Action.self, from: data)
        }
    }
}

// NotificareNotification.Action.ActionType
public extension NotificareNotification.Action {
    enum ActionType: String {
        case app = "re.notifica.action.App"
        case browser = "re.notifica.action.Browser"
        case callback = "re.notifica.action.Callback"
        case custom = "re.notifica.action.Custom"
        case mail = "re.notifica.action.Mail"
        case sms = "re.notifica.action.SMS"
        case telephone = "re.notifica.action.Telephone"
        case webView = "re.notifica.action.WebView"
    }
}

// NotificareNotification.Attachment
public extension NotificareNotification {
    struct Attachment: Codable {
        public let mimeType: String
        public let uri: String

        public init(mimeType: String, uri: String) {
            self.mimeType = mimeType
            self.uri = uri
        }

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Attachment {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Attachment.self, from: data)
        }
    }
}
