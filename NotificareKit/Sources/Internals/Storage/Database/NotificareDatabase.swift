//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

internal class NotificareDatabase: NotificareAbstractDatabase {
    internal init() {
        super.init(name: "NotificareDatabase", rebuildOnVersionChange: true)
    }

    internal func fetchEvents() async throws -> [LocalEvent] {
        ensureLoadedStores()

        return try await backgroundContext.performCompat {
            let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
            let events = try self.backgroundContext.fetch(request)
            return events.compactMap { event in
                do {
                    return try event.toLocal()
                } catch {
                    logger.warning("Unable to decode event '\(event.type ?? "")' from the database.", error: error)
                    return nil
                }
            }
        }
    }

    @discardableResult
    internal func add(_ event: LocalEvent) async throws -> NSManagedObjectID {
        ensureLoadedStores()

        let objectID = try await backgroundContext.performCompat {
            let entity = try NotificareCoreDataEvent(from: event, context: self.backgroundContext)
            return entity.objectID
        }

        await saveChanges()

        return objectID
    }

    internal func update(_ event: LocalEvent) async throws {
        ensureLoadedStores()

        guard let id = event.objectID else {
            return
        }

        try await backgroundContext.performCompat {
            let entity = try self.backgroundContext.existingObject(with: id) as! NotificareCoreDataEvent
            entity.retries = event.retries
        }

        await saveChanges()
    }

    internal func remove(_ event: LocalEvent) async {
        ensureLoadedStores()

        guard let id = event.objectID else {
            return
        }

        await backgroundContext.performCompat {
            let entity: NSManagedObject

            do {
                entity = try self.backgroundContext.existingObject(with: id)
            } catch {
                // The event for the given was removed in the meantime.
                return
            }

            guard !entity.isDeleted else {
                return
            }

            self.backgroundContext.delete(entity)
        }

        await saveChanges()
    }

    internal func clearEvents() async throws {
        ensureLoadedStores()

        try await backgroundContext.performCompat {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificareCoreDataEvent")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            try self.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: self.backgroundContext)
        }

        await saveChanges()
    }

    internal func clear() async throws {
        try await clearEvents()
    }
}
