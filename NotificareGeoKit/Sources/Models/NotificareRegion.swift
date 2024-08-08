//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareRegion: Codable, Equatable {
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

    public init(id: String, name: String, description: String?, referenceKey: String?, geometry: NotificareRegion.Geometry, advancedGeometry: NotificareRegion.AdvancedGeometry?, major: Int?, distance: Double, timeZone: String, timeZoneOffset: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.referenceKey = referenceKey
        self.geometry = geometry
        self.advancedGeometry = advancedGeometry
        self.major = major
        self.distance = distance
        self.timeZone = timeZone
        self.timeZoneOffset = timeZoneOffset
    }

    public struct Geometry: Codable, Equatable {
        public let type: String
        public let coordinate: Coordinate

        public init(type: String, coordinate: NotificareRegion.Coordinate) {
            self.type = type
            self.coordinate = coordinate
        }
    }

    public struct AdvancedGeometry: Codable, Equatable {
        public let type: String
        public let coordinates: [Coordinate]

        public init(type: String, coordinates: [NotificareRegion.Coordinate]) {
            self.type = type
            self.coordinates = coordinates
        }
    }

    public struct Coordinate: Codable, Equatable {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

// Identifiable: NotificareRegion
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareRegion: Identifiable {}

// JSON: NotificareRegion
extension NotificareRegion {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareRegion {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.self, from: data)
    }
}

// JSON: NotificareRegion.Geometry
extension NotificareRegion.Geometry {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareRegion.Geometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.Geometry.self, from: data)
    }
}

// JSON: NotificareRegion.AdvancedGeometry
extension NotificareRegion.AdvancedGeometry {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareRegion.AdvancedGeometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.AdvancedGeometry.self, from: data)
    }
}

// JSON: NotificareRegion.Coordinate
extension NotificareRegion.Coordinate {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareRegion.Coordinate {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.Coordinate.self, from: data)
    }
}
