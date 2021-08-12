//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareRegion: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let referenceKey: String?
    public let geometry: Geometry
    public let advancedGeometry: AdvancedGeometry?
    public let major: Int?
    public let distance: Double
    public let timeZone: String
    public let timeZoneOffset: Int
}

public extension NotificareRegion {
    struct Geometry: Codable {
        public let type: String
        public let coordinate: Coordinate
    }
}

public extension NotificareRegion {
    struct AdvancedGeometry: Codable {
        public let type: String
        public let coordinates: [Coordinate]
    }
}

public extension NotificareRegion {
    struct Coordinate: Codable {
        public let latitude: Double
        public let longitude: Double
    }
}
