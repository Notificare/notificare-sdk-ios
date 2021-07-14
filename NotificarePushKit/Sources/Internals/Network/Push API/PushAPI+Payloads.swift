//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct UpdateNotificationSettings: Encodable {
        let allowedUI: Bool
    }
}
