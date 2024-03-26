//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import CoreLocation
import Foundation

extension NotificareBeaconSession {
    internal func canInsertBeacon(_ beacon: CLBeacon) -> Bool {
        guard let lastEntry = beacons.last(where: { $0.major == beacon.major.intValue && $0.minor == beacon.minor.intValue }) else {
            return true
        }

        if lastEntry.proximity != beacon.proximity.rawValue {
            return true
        }

        if lastEntry.timestamp < Date(timeIntervalSinceNow: 15 * 60) {
            return true
        }

        return false
    }
}
