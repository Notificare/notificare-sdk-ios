//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareNotification: Codable {
    public let id: String?
    // public let application: Dictionary
    public let type: String
    public let time: String
    public let title: String?
    public let subtitle: String?
    public let message: String
    // public let content: [NotificareContent]?
    // public let actions: [NotificareAction]?
    // public let attachments: [NotificareAttachment]?
    // public let extra: Dictionary?
    // public let info: Dictionary?
    public let targetContentIdentifier: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case time
        case title
        case subtitle
        case message
        case targetContentIdentifier
    }
}
