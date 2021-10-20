//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareGeo: AnyObject {
    // MARK: Properties

    var delegate: NotificareGeoDelegate? { get set }

    var locationServicesEnabled: Bool { get }

    var bluetoothEnabled: Bool { get }

    // MARK: Methods

    func enableLocationUpdates()

    func disableLocationUpdates()
}
