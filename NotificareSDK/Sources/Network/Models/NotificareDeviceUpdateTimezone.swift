//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceUpdateTimezone: Encodable {
    let language: String
    let region: String
    let timeZoneOffset: Float
}
