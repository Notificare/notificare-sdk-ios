//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareRegionSession: Codable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let locations: [NotificareLocation]
}
