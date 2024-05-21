//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension NotificareInternals.PushAPI.Responses {
    struct Application: Decodable {
        internal let application: NotificareInternals.PushAPI.Models.Application
    }

    struct Tags: Decodable {
        internal let tags: [String]
    }

    struct DoNotDisturb: Decodable {
        internal let dnd: NotificareDoNotDisturb?
    }

    struct UserData: Decodable {
        internal let userData: [String: String?]?
    }

    struct DynamicLink: Decodable {
        internal let link: NotificareDynamicLink
    }

    struct Notification: Decodable {
        internal let notification: NotificareInternals.PushAPI.Models.Notification
    }

    struct UploadAsset: Decodable {
        internal let filename: String
    }
}
