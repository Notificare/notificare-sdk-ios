//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit

public struct NotificareLocation: Codable {
    public let latitude: Double
    public let longitude: Double
    public let altitude: Double
    public let course: Double
    public let speed: Double
    public let floor: Int?
    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double
    public let timestamp: Date

    public init(latitude: Double, longitude: Double, altitude: Double, course: Double, speed: Double, floor: Int?, horizontalAccuracy: Double, verticalAccuracy: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.course = course
        self.speed = speed
        self.floor = floor
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.timestamp = timestamp
    }
}

extension NotificareLocation {
    internal init(cl location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        course = location.course
        speed = location.speed
        floor = location.floor?.level
        horizontalAccuracy = location.horizontalAccuracy
        verticalAccuracy = location.verticalAccuracy
        timestamp = location.timestamp
    }
}

// JSON: NotificareLocation
extension NotificareLocation {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareLocation {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareLocation.self, from: data)
    }
}
