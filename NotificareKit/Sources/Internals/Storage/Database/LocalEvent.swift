//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import CoreData
import NotificareUtilitiesKit

internal struct LocalEvent {
    let objectID: NSManagedObjectID?
    let type: String
    let deviceId: String
    let sessionId: String?
    let notificationId: String?
    let userId: String?
    let data: NotificareAnyCodable?
    let timestamp: Int64
    let ttl: Int32
    var retries: Int16
}
