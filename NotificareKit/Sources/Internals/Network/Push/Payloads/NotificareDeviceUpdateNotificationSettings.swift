//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceUpdateNotificationSettings: Encodable {
    let language: String
    let region: String
    let allowedUI: Bool
}
