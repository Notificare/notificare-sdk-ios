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
}
