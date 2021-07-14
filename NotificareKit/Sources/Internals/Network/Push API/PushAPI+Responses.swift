//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension NotificareInternals.PushAPI.Responses {
    struct Application: Decodable {
        let application: NotificareInternals.PushAPI.Models.Application
    }

    struct Tags: Decodable {
        let tags: [String]
    }

    struct DoNotDisturb: Decodable {
        let dnd: NotificareDoNotDisturb?
    }

    struct UserData: Decodable {
        let userData: [String: String?]?
    }

    struct DynamicLink: Decodable {
        let link: NotificareDynamicLink
    }

    struct Notification: Decodable {
        let notification: NotificareInternals.PushAPI.Models.Notification
    }

    struct UploadAsset: Decodable {
        let filename: String
    }
}
