//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareEventsModule {
    func logRegionSession(_ session: NotificareRegionSession, _ completion: NotificareCallback<Void>? = nil) {
        let sessionEnd = session.end ?? Date()
        let length = sessionEnd.timeIntervalSince(session.start)

        let data: NotificareEventData = [
            "region": session.regionId,
            "start": session.start,
            "end": sessionEnd,
            "length": length,
            "locations": session.locations.map { location in
                [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "altitude": location.altitude,
                    "course": location.course,
                    "horizontalAccuracy": location.horizontalAccuracy,
                    "verticalAccuracy": location.verticalAccuracy,
                    "speed": location.speed,
                    "timestamp": location.timestamp,
                ]
            },
        ]

        log("re.notifica.event.region.Session", data: data, completion)
    }

    func logBeaconSession(_ session: NotificareBeaconSession, _ completion: NotificareCallback<Void>? = nil) {
        let sessionEnd = session.end ?? Date()
        let length = sessionEnd.timeIntervalSince(session.start)

        let data: NotificareEventData = [
            "fence": session.regionId,
            "start": session.start,
            "end": sessionEnd,
            "length": length,
            "beacons": session.beacons.map { beacon -> [String: Any] in
                var result: [String: Any] = [
                    "proximity": beacon.proximity,
                    "major": beacon.major,
                    "minor": beacon.minor,
                    "timestamp": beacon.timestamp,
                ]

                if let location = beacon.location {
                    result["location"] = [
                        "latitude": location.latitude,
                        "longitude": location.longitude,
                    ]
                }

                return result
            },
        ]

        log("re.notifica.event.beacon.Session", data: data, completion)
    }

    func logVisit(_ visit: NotificareVisit, _ completion: @escaping NotificareCallback<Void>) {
        let data: NotificareEventData = [
            "departureDate": visit.departureDate,
            "arrivalDate": visit.arrivalDate,
            "latitude": visit.latitude,
            "longitude": visit.longitude,
        ]

        log("re.notifica.event.location.Visit", data: data, completion)
    }
}
