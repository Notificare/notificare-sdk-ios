//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation

extension NotificareBeacon.Proximity {
    internal init?(_ clp: CLProximity) {
        switch clp {
        case .unknown:
            return nil
        case .immediate:
            self = .immediate
        case .near:
            self = .near
        case .far:
            self = .far
        @unknown default:
            return nil
        }
    }
}
