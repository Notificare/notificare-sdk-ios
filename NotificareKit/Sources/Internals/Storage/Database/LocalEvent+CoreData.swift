//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareUtilitiesKit

extension NotificareCoreDataEvent {
    internal convenience init(from event: LocalEvent, context: NSManagedObjectContext) throws {
        self.init(context: context)

        self.type = event.type
        self.deviceId = event.deviceId
        self.sessionId = event.sessionId
        self.notificationId = event.notificationId
        self.userId = event.userId
        self.timestamp = event.timestamp
        self.ttl = event.ttl
        self.retries = event.retries

        if let data = event.data {
            self.data = try JSONEncoder.notificare.encode(data)
        }
    }

    internal func toLocal() throws -> LocalEvent {
        LocalEvent(
            objectID: self.objectID,
            type: self.type!,
            deviceId: self.deviceId!,
            sessionId: self.sessionId,
            notificationId: self.notificationId,
            userId: self.userId,
            data: try self.data.map {
                try JSONDecoder.notificare.decode(NotificareAnyCodable.self, from: $0)
            },
            timestamp: self.timestamp,
            ttl: self.ttl,
            retries: self.retries
        )
    }
}
