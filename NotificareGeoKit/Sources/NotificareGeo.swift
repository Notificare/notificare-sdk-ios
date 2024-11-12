//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareGeo: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles geo events
    ///
    /// This property allows setting a delegate conforming to ``NotificareGeoDelegate`` to respond to various geo events,
    /// such as location updates, region monitoring events, and beacon proximity events.
    var delegate: NotificareGeoDelegate? { get set }

    /// Indicates whether location services are enabled.
    ///
    /// This property returns `true` if the location services are enabled and accessible by the application, and `false`
    /// otherwise.
    var hasLocationServicesEnabled: Bool { get }

    /// Indicates whether Bluetooth is enabled.
    ///
    /// This property returns `true` if Bluetooth is enabled and available for beacon detection and ranging, and `false`
    /// otherwise.
    var hasBluetoothEnabled: Bool { get }

    /// Provides a list of regions currently being monitored.
    ///
    /// This property returns a list of ``NotificareRegion`` objects representing the geographical regions being actively
    /// monitored for entry and exit events.
    var monitoredRegions: [NotificareRegion] { get }

    /// Provides a list of regions the user has entered.
    ///
    /// This property returns a list of ``NotificareRegion`` objects representing the regions that the user has entered and
    /// not yet exited.
    var enteredRegions: [NotificareRegion] { get }

    // MARK: Methods

    /// Enables location updates, activating location tracking, region monitoring, and beacon detection.
    ///
    /// The behavior varies based on granted permissions:
    /// - **Permission denied**: Clears the device's location information.
    /// - **Foreground location permission granted**: Tracks location only while the app is in use.
    /// - **Background location permission granted**: Enables geofencing capabilities.
    /// - **Background location + Bluetooth permissions granted**: Enables geofencing and beacon detection.
    func enableLocationUpdates()

    /// Disables location updates.
    ///
    /// This method stops receiving location updates, monitoring regions, and detecting nearby beacons.
    func disableLocationUpdates()
}
