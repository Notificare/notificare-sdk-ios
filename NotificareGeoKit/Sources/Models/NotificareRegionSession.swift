//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareRegionSession: Codable, Equatable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let locations: [NotificareLocation]
}
