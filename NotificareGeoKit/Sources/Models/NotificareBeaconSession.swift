//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareBeaconSession: Codable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let beacons: [Beacon]

    public struct Beacon: Codable {
        public let proximity: Int
        public let major: Int
        public let minor: Int
        public let location: Location?
        public let timestamp: Date

        public struct Location: Codable {
            public let latitude: Double
            public let longitude: Double
        }
    }
}
