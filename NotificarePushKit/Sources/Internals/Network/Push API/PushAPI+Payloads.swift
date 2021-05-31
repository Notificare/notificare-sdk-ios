//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Payloads {
    struct UpdateNotificationSettings: Encodable {
        let allowedUI: Bool
    }
}
