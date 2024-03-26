//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

extension NotificareRegion {
    internal var isPolygon: Bool {
        advancedGeometry != nil
    }

    internal func toCLRegion(with manager: CLLocationManager) -> CLRegion {
        CLCircularRegion(
            center: CLLocationCoordinate2D(
                latitude: geometry.coordinate.latitude,
                longitude: geometry.coordinate.longitude
            ),
            radius: distance < manager.maximumRegionMonitoringDistance ? distance : manager.maximumRegionMonitoringDistance,
            identifier: id
        )
    }

    internal func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if isPolygon, let polygon = MKPolygon(region: self) {
            return polygon.contains(coordinate)
        }

        let circle = CLCircularRegion(
            center: CLLocationCoordinate2D(
                latitude: self.geometry.coordinate.latitude,
                longitude: self.geometry.coordinate.longitude
            ),
            radius: self.distance,
            identifier: self.id
        )

        return circle.contains(coordinate)
    }
}
