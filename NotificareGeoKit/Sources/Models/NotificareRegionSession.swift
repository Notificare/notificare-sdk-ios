//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareRegionSession: Codable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let locations: [Location]

    public struct Location: Codable {
        public let latitude: Double
        public let longitude: Double
        public let altitude: Double
        public let course: Double
        public let speed: Double
        public let horizontalAccuracy: Double
        public let verticalAccuracy: Double
        public let timestamp: Date
    }
}
