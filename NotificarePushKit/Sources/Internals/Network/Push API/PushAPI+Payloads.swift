//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Payloads {
    internal struct UpdateNotificationSettings: Encodable {
        internal let allowedUI: Bool
    }

    internal struct RegisterLiveActivity: Encodable {
        internal let activity: String
        internal let token: String
        internal let deviceID: String
        internal let topics: [String]?
    }
}
