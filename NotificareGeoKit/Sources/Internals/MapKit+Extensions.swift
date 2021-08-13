//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import MapKit

internal extension MKPolygon {
    convenience init?(region: NotificareRegion) {
        guard region.isPolygon, let advancedGeometry = region.advancedGeometry else {
            return nil
        }

        let points = advancedGeometry.coordinates.map { coordinate in
            CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }

        self.init(coordinates: points, count: points.count)
    }

    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let renderer = MKPolygonRenderer(polygon: self)
        let point = renderer.point(for: MKMapPoint(coordinate))

        return renderer.path.contains(point)
    }
}
