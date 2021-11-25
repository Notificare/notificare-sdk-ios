//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

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

    public struct Geometry: Codable {
        public let type: String
        public let coordinate: Coordinate
    }

    public struct AdvancedGeometry: Codable {
        public let type: String
        public let coordinates: [Coordinate]
    }

    public struct Coordinate: Codable {
        public let latitude: Double
        public let longitude: Double
    }
}

// JSON: NotificareRegion
public extension NotificareRegion {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareRegion {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.self, from: data)
    }
}

// JSON: NotificareRegion.Geometry
public extension NotificareRegion.Geometry {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareRegion.Geometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.Geometry.self, from: data)
    }
}

// JSON: NotificareRegion.AdvancedGeometry
public extension NotificareRegion.AdvancedGeometry {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareRegion.AdvancedGeometry {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.AdvancedGeometry.self, from: data)
    }
}

// JSON: NotificareRegion.Coordinate
public extension NotificareRegion.Coordinate {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareRegion.Coordinate {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareRegion.Coordinate.self, from: data)
    }
}
