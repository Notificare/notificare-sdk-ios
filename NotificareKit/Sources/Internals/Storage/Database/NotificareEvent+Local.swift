//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareUtilitiesKit

extension NotificareEvent {
    internal init(from local: LocalEvent) {
        self.init(
            type: local.type,
            timestamp: local.timestamp,
            deviceId: local.deviceId,
            sessionId: local.sessionId,
            notificationId: local.notificationId,
            userId: local.userId,
            data: local.data?.value as? NotificareEventData
        )
    }

    internal func toLocal() -> LocalEvent {
        LocalEvent(
            objectID: nil,
            type: type,
            deviceId: deviceId,
            sessionId: sessionId,
            notificationId: notificationId,
            userId: userId,
            data: NotificareAnyCodable(data),
            timestamp: timestamp,
            ttl: 24 * 60 * 60, // 24 hours in seconds
            retries: 0
        )
    }
}
