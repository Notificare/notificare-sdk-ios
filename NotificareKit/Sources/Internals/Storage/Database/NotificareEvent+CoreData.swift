//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

extension NotificareEvent {
    func toManaged(context: NSManagedObjectContext) -> NotificareCoreDataEvent {
        let event = NotificareCoreDataEvent(context: context)

        event.type = type
        event.timestamp = timestamp
        event.deviceId = deviceId
        event.sessionId = sessionId
        event.notificationId = notificationId
        event.userId = userId
        event.ttl = 24 * 60 * 60 // 24 hours
        event.retries = 0
        event.data = try? JSONEncoder().encode(data)

        return event
    }

    init(from managed: NotificareCoreDataEvent) {
        var eventData: NotificareEventData?
        if let data = managed.data {
            eventData = try? JSONDecoder().decode(NotificareEventData.self, from: data)
        }

        self.init(
            type: managed.type!,
            timestamp: managed.timestamp,
            deviceId: managed.deviceId!,
            sessionId: managed.sessionId,
            notificationId: managed.notificationId,
            userId: managed.userId,
            data: eventData
        )
    }
}
