//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareGeoDelegate: AnyObject {
    func notificare(_ notificareGeo: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion)
}

public extension NotificareGeoDelegate {
    func notificare(_: NotificareGeo, didRange _: [NotificareBeacon], in _: NotificareRegion) {}
}
