//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Models {
    internal struct Region: Decodable, Equatable {
        internal let _id: String
        internal let name: String
        internal let description: String?
        internal let referenceKey: String?
        internal let geometry: Geometry
        internal let advancedGeometry: AdvancedGeometry?
        internal let major: Int?
        internal let distance: Double
        internal let timezone: String
        internal let timeZoneOffset: Int

        internal struct Geometry: Decodable, Equatable {
            internal let type: String
            internal let coordinates: [Double]
        }

        internal struct AdvancedGeometry: Decodable, Equatable {
            internal let type: String
            internal let coordinates: [[[Double]]]
        }

        internal func toModel() -> NotificareRegion {
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

    internal struct Beacon: Decodable {
        internal let _id: String
        internal let name: String
        internal let major: Int
        internal let minor: Int
        internal let triggers: Bool

        internal func toModel() -> NotificareBeacon {
            NotificareBeacon(
                id: _id,
                name: name,
                major: major,
                minor: minor,
                triggers: triggers
            )
        }
    }
}
