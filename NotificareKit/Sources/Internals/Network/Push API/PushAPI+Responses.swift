//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Responses {
    struct Application: Decodable {
        let application: PushAPI.Models.Application
    }

    struct Tags: Decodable {
        let tags: [String]
    }

    struct DoNotDisturb: Decodable {
        let dnd: NotificareDoNotDisturb?
    }

    struct UserData: Decodable {
        let userData: NotificareUserData?
    }

    struct DynamicLink: Decodable {
        let link: NotificareDynamicLink
    }

    struct Notification: Decodable {
        let notification: PushAPI.Models.Notification
    }

    struct UploadAsset: Decodable {
        let filename: String
    }
}
