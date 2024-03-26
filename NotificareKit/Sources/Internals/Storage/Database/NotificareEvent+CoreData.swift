//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

extension NotificareEvent {
    internal func toManaged(context: NSManagedObjectContext) -> NotificareCoreDataEvent {
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

    internal init(from managed: NotificareCoreDataEvent) throws {
        var eventData: NotificareEventData?
        if
            let data = managed.data,
            let decoded = try? NotificareUtils.jsonDecoder.decode(NotificareAnyCodable.self, from: data)
        {
            eventData = decoded.value as? NotificareEventData
        }

        guard let type = managed.type else {
            throw NotificareError.invalidArgument(message: "Event entity is missing the 'type' attribute.")
        }

        guard let deviceId = managed.deviceId else {
            throw NotificareError.invalidArgument(message: "Event entity is missing the 'deviceId' attribute.")
        }

        self.init(
            type: type,
            timestamp: managed.timestamp,
            deviceId: deviceId,
            sessionId: managed.sessionId,
            notificationId: managed.notificationId,
            userId: managed.userId,
            data: eventData
        )
    }
}
