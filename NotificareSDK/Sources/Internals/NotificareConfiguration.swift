//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareConfiguration: Codable {
    let autoLaunch: Bool
    let swizzlingEnabled: Bool
    let services: String?
    let production: Bool
    let developmentApplicationKey: String?
    let developmentApplicationSecret: String?
    let productionApplicationKey: String?
    let productionApplicationSecret: String?
}
