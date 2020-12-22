//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceUpdateLocation: Encodable {
    let language: String
    let region: String
    let latitude: Float?
    let longitude: Float?
    let altitude: Float?
    let locationAccuracy: Float?
    let speed: Float?
    let course: Float?
    let country: String?
    let floor: Float?
    let locationServicesAuthStatus: String?
    let locationServicesAccuracyAuth: String?

    enum CodingKeys: String, CodingKey {
        case language,
            region,
            latitude,
            longitude,
            altitude,
            locationAccuracy,
            speed,
            course,
            country,
            floor,
            locationServicesAuthStatus,
            locationServicesAccuracyAuth
    }

    func encode(to encoder: Encoder) throws {
        // NOTE: manual Encodable implementation to force nils to be encoded in the payload.
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(language, forKey: .language)
        try container.encode(region, forKey: .region)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(locationAccuracy, forKey: .locationAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(country, forKey: .country)
        try container.encode(floor, forKey: .floor)
        try container.encode(locationServicesAuthStatus, forKey: .locationServicesAuthStatus)
        try container.encode(locationServicesAccuracyAuth, forKey: .locationServicesAccuracyAuth)
    }
}
