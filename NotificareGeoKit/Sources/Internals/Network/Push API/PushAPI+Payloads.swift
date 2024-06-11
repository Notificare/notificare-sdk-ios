//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Payloads {
    internal struct UpdateDeviceLocation: Encodable {
        @EncodeNull internal var latitude: Double?
        @EncodeNull internal var longitude: Double?
        @EncodeNull internal var altitude: Double?
        @EncodeNull internal var locationAccuracy: Double?
        @EncodeNull internal var speed: Double?
        @EncodeNull internal var course: Double?
        @EncodeNull internal var country: String?
        @EncodeNull internal var floor: Int?
        @EncodeNull internal var locationServicesAuthStatus: NotificareGeoImpl.AuthorizationMode?
        @EncodeNull internal var locationServicesAccuracyAuth: NotificareGeoImpl.AccuracyMode?
    }

    internal struct RegionTrigger: Encodable {
        internal let deviceID: String
        internal let region: String
    }

    internal struct BeaconTrigger: Encodable {
        internal let deviceID: String
        internal let beacon: String
    }

    internal struct BluetoothStateUpdate: Encodable {
        internal let bluetoothEnabled: Bool
    }
}
