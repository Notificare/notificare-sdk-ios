//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct UpdateNotificationSettings: Encodable {
        internal let allowedUI: Bool
    }

    struct RegisterLiveActivity: Encodable {
        internal let activity: String
        internal let token: String
        internal let deviceID: String
        internal let topics: [String]?
    }
}
