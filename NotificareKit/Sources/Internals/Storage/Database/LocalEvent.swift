//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import CoreData
import NotificareUtilitiesKit

internal struct LocalEvent {
    internal let objectID: NSManagedObjectID?
    internal let type: String
    internal let deviceId: String
    internal let sessionId: String?
    internal let notificationId: String?
    internal let userId: String?
    internal let data: NotificareAnyCodable?
    internal let timestamp: Int64
    internal let ttl: Int32
    internal var retries: Int16
}
