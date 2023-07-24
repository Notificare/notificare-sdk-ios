//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareGeo: AnyObject {
    // MARK: Properties

    var delegate: NotificareGeoDelegate? { get set }

    var hasLocationServicesEnabled: Bool { get }

    var hasBluetoothEnabled: Bool { get }

    var monitoredRegions: [NotificareRegion] { get }

    var enteredRegions: [NotificareRegion] { get }

    // MARK: Methods

    func enableLocationUpdates()

    func disableLocationUpdates()
}
