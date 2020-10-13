//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceUpdateBackgroundAppRefresh: Encodable {
    let language: String
    let region: String
    let backgroundAppRefresh: Bool
}
