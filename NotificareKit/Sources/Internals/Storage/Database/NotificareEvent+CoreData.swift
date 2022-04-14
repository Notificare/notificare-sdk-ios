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

        if let data = data {
            event.data = try? NotificareUtils.jsonEncoder.encode(NotificareAnyCodable(data))
        } else {
            event.data = nil
        }

        return event
    }

    init(from managed: NotificareCoreDataEvent) {
        var eventData: NotificareEventData?
        if let data = managed.data,
           let decoded = try? NotificareUtils.jsonDecoder.decode(NotificareAnyCodable.self, from: data)
        {
            eventData = decoded.value as? NotificareEventData
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
