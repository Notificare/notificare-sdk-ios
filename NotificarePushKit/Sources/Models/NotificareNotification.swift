//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareNotification {
    public let id: String?
    // public let application: Dictionary
    public let type: String
    public let time: Date
    public let title: String?
    public let subtitle: String?
    public let message: String
    public let content: [Content]
    public let actions: [Action]
    public let attachments: [Attachment]
    public let extra: [String: Any]
    public let info: [String: Any]
    public let targetContentIdentifier: String?
}

extension NotificareNotification: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case time
        case title
        case subtitle
        case message
        case content
        case actions
        case attachments
        case extra
        case info
        case targetContentIdentifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        time = try container.decode(Date.self, forKey: .time)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        message = try container.decode(String.self, forKey: .message)

        if container.contains(.content) {
            content = try container.decode([Content].self, forKey: .content)
        } else {
            content = []
        }

        if container.contains(.actions) {
            actions = try container.decode([Action].self, forKey: .actions)
        } else {
            actions = []
        }

        if container.contains(.attachments) {
            attachments = try container.decode([Attachment].self, forKey: .attachments)
        } else {
            attachments = []
        }

        if container.contains(.extra) {
            extra = try container.decode([String: Any].self, forKey: .extra)
        } else {
            extra = [:]
        }

        if container.contains(.info) {
            info = try container.decode([String: Any].self, forKey: .info)
        } else {
            info = [:]
        }

        targetContentIdentifier = try container.decodeIfPresent(String.self, forKey: .targetContentIdentifier)
    }
}

// NotificareNotification.Content
public extension NotificareNotification {
    struct Content: Decodable {
        public let type: String
        public let data: Any

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)

            if let str = try? container.decode(String.self, forKey: .data) {
                data = str
            } else {
                data = try container.decode([String: Any].self, forKey: .data)
            }
        }

        enum CodingKeys: String, CodingKey {
            case type
            case data
        }
    }
}

// NotificareNotification.Action
public extension NotificareNotification {
    struct Action: Decodable {
        public let type: String
        public let label: String
        public let target: String?
        public let keyboard: Bool
        public let camera: Bool
    }
}

// NotificareNotification.ActionData
public extension NotificareNotification {
    struct ActionData: Decodable {
        public let identifier: String
        public let userText: String?
    }
}

// NotificareNotification.Attachment
public extension NotificareNotification {
    struct Attachment: Decodable {
        public let mimeType: String
        public let uri: String
    }
}
