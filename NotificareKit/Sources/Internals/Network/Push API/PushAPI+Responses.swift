//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension NotificareInternals.PushAPI.Responses {
    internal struct Application: Decodable {
        internal let application: NotificareInternals.PushAPI.Models.Application
    }

    internal struct CreateDevice: Decodable {
        internal let device: Device

        internal struct Device: Decodable {
            internal let deviceID: String
        }
    }

    internal struct Tags: Decodable {
        internal let tags: [String]
    }

    internal struct DoNotDisturb: Decodable {
        internal let dnd: NotificareDoNotDisturb?
    }

    internal struct UserData: Decodable {
        internal let userData: [String: String?]?
    }

    internal struct DynamicLink: Decodable {
        internal let link: NotificareDynamicLink
    }

    internal struct Notification: Decodable {
        internal let notification: NotificareInternals.PushAPI.Models.Notification
    }

    internal struct UploadAsset: Decodable {
        internal let filename: String
    }
}
