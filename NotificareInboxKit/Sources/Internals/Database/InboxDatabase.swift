//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareKit

internal class InboxDatabase: NotificareAbstractDatabase {
    internal init() {
        super.init(
            name: "NotificareInboxDatabase",
            rebuildOnVersionChange: true,
            mergePolicy: .overwrite
        )
    }

    internal func find() async throws -> [LocalInboxItem] {
        ensureLoadedStores()

        return try await backgroundContext.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")

            // NOTE: Make sure the cached items are always sorted by date descending.
            // The most recent one is important to be the first as the sync logic relies on it.
            request.sortDescriptors = [
                NSSortDescriptor(key: #keyPath(InboxItemEntity.time), ascending: false),
            ]

            let entities = try self.backgroundContext.fetch(request)
            return entities.compactMap { entity in
                do {
                    return try entity.toLocal()
                } catch {
                    logger.warning("Unable to decode inbox item '\(entity.id ?? "")' from the database.", error: error)
                    return nil
                }
            }
        }
    }

    @discardableResult
    internal func add(_ item: LocalInboxItem) async throws -> NSManagedObjectID {
        ensureLoadedStores()

        let objectID = try await backgroundContext.performCompat {
            let entity = try InboxItemEntity(from: item, context: self.backgroundContext)
            return entity.objectID
        }

        await saveChanges()

        return objectID
    }

    internal func update(_ item: LocalInboxItem) async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "id = %@", item.id)
            request.fetchLimit = 1

            guard let entity = try self.backgroundContext.fetch(request).first else {
                return
            }

            try entity.setNotification(item.notification)
            entity.opened = item.opened
        }

        await saveChanges()
    }

    internal func remove(id: String) async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "id = %@", id)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try self.backgroundContext.execute(deleteRequest)
        }

        await saveChanges()
    }

    internal func remove(notificationId: String) async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            request.predicate = NSPredicate(format: "notificationId = %@", notificationId)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try self.backgroundContext.execute(deleteRequest)
        }

        await saveChanges()
    }

    internal func clear() async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: self.backgroundContext)
        }
    }
}
