//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareBeaconSession: Codable, Equatable {
    public let regionId: String
    public let start: Date
    public let end: Date?
    public let beacons: [Beacon]

    public init(regionId: String, start: Date, end: Date?, beacons: [Beacon]) {
        self.regionId = regionId
        self.start = start
        self.end = end
        self.beacons = beacons
    }

    public struct Beacon: Codable, Equatable {
        public let proximity: Int
        public let major: Int
        public let minor: Int
        public let location: Location?
        public let timestamp: Date

        public init(proximity: Int, major: Int, minor: Int, location: Location?, timestamp: Date) {
            self.proximity = proximity
            self.major = major
            self.minor = minor
            self.location = location
            self.timestamp = timestamp
        }

        public struct Location: Codable, Equatable {
            public let latitude: Double
            public let longitude: Double

            public init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
        }
    }
}
