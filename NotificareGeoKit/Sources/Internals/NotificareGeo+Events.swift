//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareEventsModule {
    func logRegionSession(_ session: NotificareRegionSession, _ completion: NotificareCallback<Void>) {
        let sessionEnd = session.end ?? Date()
        let length = sessionEnd.timeIntervalSince(session.start)

        let data: NotificareEventData = [
            "region": session.regionId,
            "start": session.start,
            "end": sessionEnd,
            "length": length,
            "locations": session.locations.map { location -> [String: Any] in
                var result: [String: Any] = [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "altitude": location.altitude,
                    "course": location.course,
                    "speed": location.speed,
                    "horizontalAccuracy": location.horizontalAccuracy,
                    "verticalAccuracy": location.verticalAccuracy,
                    "timestamp": location.timestamp,
                ]

                if let floor = location.floor {
                    result["floor"] = floor
                }

                return result
            },
        ]

        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.region.Session", data: data, completion)
    }

    func logBeaconSession(_ session: NotificareBeaconSession, _ completion: NotificareCallback<Void>) {
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

        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.beacon.Session", data: data, completion)
    }

    func logVisit(_ visit: NotificareVisit, _ completion: @escaping NotificareCallback<Void>) {
        let data: NotificareEventData = [
            "departureDate": visit.departureDate,
            "arrivalDate": visit.arrivalDate,
            "latitude": visit.latitude,
            "longitude": visit.longitude,
        ]

        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.location.Visit", data: data, completion)
    }
}
