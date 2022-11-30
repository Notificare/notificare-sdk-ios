//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct UpdateNotificationSettings: Encodable {
        let allowedUI: Bool
    }

    struct RegisterLiveActivity: Encodable {
        let activity: String
        let token: String
        let deviceID: String
        let topics: [String]?
    }
}
