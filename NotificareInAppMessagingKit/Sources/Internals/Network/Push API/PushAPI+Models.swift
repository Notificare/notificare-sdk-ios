//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Message: Decodable {
        let _id: String
        let name: String
        let type: String
        let context: [String]
        let title: String?
        let message: String?
        let image: String?
        let landscapeImage: String?
        let delaySeconds: Int
        let primaryAction: Action?
        let secondaryAction: Action?

        struct Action: Decodable {
            let label: String?
            let destructive: Bool
            let url: String?
        }

        func toModel() -> NotificareInAppMessage {
            NotificareInAppMessage(
                id: _id,
                name: name,
                type: type,
                context: context,
                title: title,
                message: message,
                image: image,
                landscapeImage: landscapeImage,
                delaySeconds: delaySeconds,
                primaryAction: primaryAction.map {
                    NotificareInAppMessage.Action(
                        label: $0.label,
                        destructive: $0.destructive,
                        url: $0.url
                    )
                },
                secondaryAction: secondaryAction.map {
                    NotificareInAppMessage.Action(
                        label: $0.label,
                        destructive: $0.destructive,
                        url: $0.url
                    )
                }
            )
        }
    }
}

internal extension NotificareInternals.PushAPI.Models.Message {
    private enum CodingKeys: String, CodingKey {
        case _id
        case name
        case type
        case context
        case title
        case message
        case image
        case landscapeImage
        case delaySeconds
        case primaryAction
        case secondaryAction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decode(String.self, forKey: ._id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        context = try container.decodeIfPresent([String].self, forKey: .context) ?? []
        title = try container.decodeIfPresent(String.self, forKey: .title)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        landscapeImage = try container.decodeIfPresent(String.self, forKey: .landscapeImage)
        delaySeconds = try container.decodeIfPresent(Int.self, forKey: .delaySeconds) ?? 0
        primaryAction = try container.decodeIfPresent(Action.self, forKey: .primaryAction)
        secondaryAction = try container.decodeIfPresent(Action.self, forKey: .secondaryAction)
    }
}
