//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Payloads {
    struct UpdateDeviceLocation: Encodable {
        internal let latitude: Double?
        internal let longitude: Double?
        internal let altitude: Double?
        internal let locationAccuracy: Double?
        internal let speed: Double?
        internal let course: Double?
        internal let country: String?
        internal let floor: Int?
        internal let locationServicesAuthStatus: NotificareGeoImpl.AuthorizationMode?
        internal let locationServicesAccuracyAuth: NotificareGeoImpl.AccuracyMode?

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

        internal func encode(to encoder: Encoder) throws {
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
        internal let deviceID: String
        internal let region: String
    }

    struct BeaconTrigger: Encodable {
        internal let deviceID: String
        internal let beacon: String
    }

    struct BluetoothStateUpdate: Encodable {
        internal let bluetoothEnabled: Bool
    }
}
