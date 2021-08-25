//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct UpdateDeviceLocation: Encodable {
        let latitude: Double
        let longitude: Double
        let altitude: Double
        let locationAccuracy: Double?
        let speed: Double?
        let course: Double?
        let country: String?
        let floor: Int?
        let locationServicesAuthStatus: NotificareGeo.AuthorizationMode
        let locationServicesAccuracyAuth: NotificareGeo.AccuracyMode

        private enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case altitude
            case locationAccuracy
            case speed
            case course
            case country
            case floor
            case locationServicesAuthStatus
            case locationServicesAccuracyAuth
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
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

    struct RegionTrigger: Encodable {
        let deviceID: String
        let region: String
    }

    struct BeaconTrigger: Encodable {
        let deviceID: String
        let beacon: String
    }

    struct BluetoothStateUpdate: Encodable {
        let bluetoothEnabled: Bool
    }
}
