//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit

public protocol NotificareGeoDelegate: AnyObject {
    /// Called when the device's location is updated.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - locations: A list of the updated ``NotificareLocation``
    func notificare(_ notificareGeo: NotificareGeo, didUpdateLocations locations: [NotificareLocation])

    /// Called when the location services failed.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - error: The error associated to the location services failure.
    func notificare(_ notificareGeo: NotificareGeo, didFailWith error: Error)

    /// Called when the device starts monitoring a ``NotificareRegion``.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - region: The ``NotificareRegion`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didStartMonitoringFor region: NotificareRegion)

    /// Called when the device starts monitoring a ``NotificareBeacon``.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - beacon: The ``NotificareBeacon`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didStartMonitoringFor beacon: NotificareBeacon)

    /// Called when monitoring a ``NotificareRegion`` fails.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - region: The ``NotificareRegion`` being monitored.
    ///   - error: The error associated to the location services failure.
    func notificare(_ notificareGeo: NotificareGeo, monitoringDidFailFor region: NotificareRegion, with error: Error)

    /// Called when monitoring a ``NotificareBeacon`` fails.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - beacon: The ``NotificareBeacon`` being monitored.
    ///   - error: The error associated to the location services failure.
    func notificare(_ notificareGeo: NotificareGeo, monitoringDidFailFor beacon: NotificareBeacon, with error: Error)

    /// Called when the state of a monitored region is determined.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - state: The determined state of the region.
    ///   - region: The ``NotificareRegion`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didDetermineState state: CLRegionState, for region: NotificareRegion)

    /// Called when the state of a monitored beacon is determined.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - state: The determined state of the beacon.
    ///   - beacon: The ``NotificareBeacon`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didDetermineState state: CLRegionState, for beacon: NotificareBeacon)

    /// Called when the device enters a monitored region.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - region: The ``NotificareRegion`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didEnter region: NotificareRegion)

    /// Called when the device enters a monitored beacon.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - beacon: The ``NotificareBeacon`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didEnter beacon: NotificareBeacon)

    /// Called when the device exits a monitored region.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - region: The ``NotificareRegion`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didExit region: NotificareRegion)

    /// Called when the device exits a monitored beacon.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - beacon: The ``NotificareBeacon`` being monitored.
    func notificare(_ notificareGeo: NotificareGeo, didExit beacon: NotificareBeacon)

    /// Called when the device registers a location visit.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - visit: The ``NotificareVisit`` object representing the details of the visit.
    func notificare(_ notificareGeo: NotificareGeo, didVisit visit: NotificareVisit)

    /// Called when there is an update to the device’s heading.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - heading: The ``NotificareHeading`` object containing details of the updated heading.
    func notificare(_ notificareGeo: NotificareGeo, didUpdateHeading heading: NotificareHeading)

    /// Called when the device detects or updates proximity to beacons within a specified region.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - beacons: A list of detected ``NotificareBeacon``.
    ///   - region: The ``NotificareRegion`` where the beacons are being ranged.
    func notificare(_ notificareGeo: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion)

    /// Called when beacon ranging fails within a specified region.
    /// - Parameters:
    ///   - notificareGeo: The NotificareGeo object instance.
    ///   - region: The ``NotificareRegion`` where the beacons are being ranged.
    ///   - error: The error associated with the failure.
    func notificare(_ notificareGeo: NotificareGeo, didFailRangingFor region: NotificareRegion, with error: Error)
}

extension NotificareGeoDelegate {
    public func notificare(_: NotificareGeo, didUpdateLocations _: [NotificareLocation]) {}

    public func notificare(_: NotificareGeo, didFailWith _: Error) {}

    public func notificare(_: NotificareGeo, didStartMonitoringFor _: NotificareRegion) {}

    public func notificare(_: NotificareGeo, didStartMonitoringFor _: NotificareBeacon) {}

    public func notificare(_: NotificareGeo, monitoringDidFailFor _: NotificareRegion, with _: Error) {}

    public func notificare(_: NotificareGeo, monitoringDidFailFor _: NotificareBeacon, with _: Error) {}

    public func notificare(_: NotificareGeo, didDetermineState _: CLRegionState, for _: NotificareRegion) {}

    public func notificare(_: NotificareGeo, didDetermineState _: CLRegionState, for _: NotificareBeacon) {}

    public func notificare(_: NotificareGeo, didEnter _: NotificareRegion) {}

    public func notificare(_: NotificareGeo, didEnter _: NotificareBeacon) {}

    public func notificare(_: NotificareGeo, didExit _: NotificareRegion) {}

    public func notificare(_: NotificareGeo, didExit _: NotificareBeacon) {}

    public func notificare(_: NotificareGeo, didVisit _: NotificareVisit) {}

    public func notificare(_: NotificareGeo, didUpdateHeading _: NotificareHeading) {}

    public func notificare(_: NotificareGeo, didRange _: [NotificareBeacon], in _: NotificareRegion) {}

    public func notificare(_: NotificareGeo, didFailRangingFor _: NotificareRegion, with _: Error) {}
}
