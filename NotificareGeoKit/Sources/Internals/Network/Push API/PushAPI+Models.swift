//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Region: Decodable {
        let _id: String
        let name: String
        let description: String?
        let referenceKey: String?
        let geometry: Geometry
        let advancedGeometry: AdvancedGeometry?
        let major: Int?
        let distance: Double
        let timezone: String
        let timeZoneOffset: Int

        struct Geometry: Decodable {
            let type: String
            let coordinates: [Double]
        }

        struct AdvancedGeometry: Decodable {
            let type: String
            let coordinates: [[[Double]]]
        }

        func toModel() -> NotificareRegion {
            NotificareRegion(
                id: _id,
                name: name,
                description: description,
                referenceKey: referenceKey,
                geometry: NotificareRegion.Geometry(
                    type: geometry.type,
                    coordinate: NotificareRegion.Coordinate(
                        latitude: geometry.coordinates[1],
                        longitude: geometry.coordinates[0]
                    )
                ),
                advancedGeometry: advancedGeometry.flatMap { geometry in
                    guard let coordinates = geometry.coordinates.first else {
                        return nil
                    }

                    return NotificareRegion.AdvancedGeometry(
                        type: geometry.type,
                        coordinates: coordinates.map { coordinates in
                            NotificareRegion.Coordinate(
                                latitude: coordinates[1],
                                longitude: coordinates[0]
                            )
                        }
                    )
                },
                major: major,
                distance: distance,
                timeZone: timezone,
                timeZoneOffset: timeZoneOffset
            )
        }
    }
}
