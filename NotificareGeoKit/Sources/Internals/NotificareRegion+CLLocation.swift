//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation

internal extension NotificareRegion {
    func toCLRegion(with manager: CLLocationManager) -> CLRegion {
        CLCircularRegion(
            center: CLLocationCoordinate2D(
                latitude: geometry.coordinate.latitude,
                longitude: geometry.coordinate.longitude
            ),
            radius: distance < manager.maximumRegionMonitoringDistance ? distance : manager.maximumRegionMonitoringDistance,
            identifier: id
        )
    }
}
