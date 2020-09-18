//
//  NotificareEvent+CoreData.swift
//  Notificare
//
//  Created by Helder Pinhal on 04/09/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import CoreData

extension NotificareEvent {

    func toManaged(context: NSManagedObjectContext) -> NotificareCoreDataEvent {
        let event = NotificareCoreDataEvent(context: context)

        event.type = self.type
        event.timestamp = self.timestamp
        event.deviceId = self.deviceId
        event.sessionId = self.sessionId
        event.notificationId = self.notificationId
        event.userId = self.userId
        event.ttl = 24 * 60 * 60 // 24 hours
        event.retries = 0
        event.data = try? JSONEncoder().encode(self.data)

        return event
    }

    init(from managed: NotificareCoreDataEvent) {
        var eventData: NotificareEventData? = nil
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
