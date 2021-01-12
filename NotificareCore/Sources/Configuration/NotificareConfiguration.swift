//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareConfiguration: Codable {
    public let autoLaunch: Bool
    public let swizzlingEnabled: Bool
    public let crashReportsEnabled: Bool
    public let services: String?
    public let production: Bool
    public let developmentApplicationKey: String?
    public let developmentApplicationSecret: String?
    public let productionApplicationKey: String?
    public let productionApplicationSecret: String?
}
