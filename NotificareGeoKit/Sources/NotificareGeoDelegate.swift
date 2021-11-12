//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit

public protocol NotificareGeoDelegate: AnyObject {
    func notificare(_ notificareGeo: NotificareGeo, didUpdateLocations locations: [NotificareLocation])

    func notificare(_ notificareGeo: NotificareGeo, didFailWith error: Error)

    func notificare(_ notificareGeo: NotificareGeo, didStartMonitoringFor region: NotificareRegion)

    func notificare(_ notificareGeo: NotificareGeo, didStartMonitoringFor beacon: NotificareBeacon)

    func notificare(_ notificareGeo: NotificareGeo, monitoringDidFailFor region: NotificareRegion, with error: Error)

    func notificare(_ notificareGeo: NotificareGeo, monitoringDidFailFor beacon: NotificareBeacon, with error: Error)

    func notificare(_ notificareGeo: NotificareGeo, didDetermineState state: CLRegionState, for region: NotificareRegion)

    func notificare(_ notificareGeo: NotificareGeo, didDetermineState state: CLRegionState, for beacon: NotificareBeacon)

    func notificare(_ notificareGeo: NotificareGeo, didEnter region: NotificareRegion)

    func notificare(_ notificareGeo: NotificareGeo, didEnter beacon: NotificareBeacon)

    func notificare(_ notificareGeo: NotificareGeo, didExit region: NotificareRegion)

    func notificare(_ notificareGeo: NotificareGeo, didExit beacon: NotificareBeacon)

    func notificare(_ notificareGeo: NotificareGeo, didVisit visit: NotificareVisit)

    func notificare(_ notificareGeo: NotificareGeo, didUpdateHeading heading: NotificareHeading)

    func notificare(_ notificareGeo: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion)

    func notificare(_ notificareGeo: NotificareGeo, didFailRangingFor region: NotificareRegion, with error: Error)
}

public extension NotificareGeoDelegate {
    func notificare(_: NotificareGeo, didUpdateLocations _: [NotificareLocation]) {}

    func notificare(_: NotificareGeo, didFailWith _: Error) {}

    func notificare(_: NotificareGeo, didStartMonitoringFor _: NotificareRegion) {}

    func notificare(_: NotificareGeo, didStartMonitoringFor _: NotificareBeacon) {}

    func notificare(_: NotificareGeo, monitoringDidFailFor _: NotificareRegion, with _: Error) {}

    func notificare(_: NotificareGeo, monitoringDidFailFor _: NotificareBeacon, with _: Error) {}

    func notificare(_: NotificareGeo, didDetermineState _: CLRegionState, for _: NotificareRegion) {}

    func notificare(_: NotificareGeo, didDetermineState _: CLRegionState, for _: NotificareBeacon) {}

    func notificare(_: NotificareGeo, didEnter _: NotificareRegion) {}

    func notificare(_: NotificareGeo, didEnter _: NotificareBeacon) {}

    func notificare(_: NotificareGeo, didExit _: NotificareRegion) {}

    func notificare(_: NotificareGeo, didExit _: NotificareBeacon) {}

    func notificare(_: NotificareGeo, didVisit _: NotificareVisit) {}

    func notificare(_: NotificareGeo, didUpdateHeading _: NotificareHeading) {}

    func notificare(_: NotificareGeo, didRange _: [NotificareBeacon], in _: NotificareRegion) {}

    func notificare(_: NotificareGeo, didFailRangingFor _: NotificareRegion, with _: Error) {}
}
