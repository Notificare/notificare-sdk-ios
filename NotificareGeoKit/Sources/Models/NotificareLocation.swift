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
}

internal extension NotificareLocation {
    init(cl location: CLLocation) {
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
