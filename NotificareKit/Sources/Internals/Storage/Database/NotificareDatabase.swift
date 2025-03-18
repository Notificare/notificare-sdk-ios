//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

internal class NotificareDatabase: NotificareAbstractDatabase {
    internal init() {
        super.init(name: "NotificareDatabase", rebuildOnVersionChange: true)
    }

    internal func add(_ event: NotificareEvent) async {
        ensureLoadedStores()

        await backgroundContext.performCompat {
            _ = event.toManaged(context: self.backgroundContext)
        }

        await saveChanges()
    }

    internal func remove(_ event: NotificareCoreDataEvent) async {
        ensureLoadedStores()

        await backgroundContext.performCompat {
            let entity = self.backgroundContext.object(with: event.objectID)
            self.backgroundContext.delete(entity)
        }

        await saveChanges()
    }

    internal func fetchEvents() async throws -> [NotificareCoreDataEvent] {
        ensureLoadedStores()

        return try await backgroundContext.performCompat {
            let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
            return try self.backgroundContext.fetch(request)
        }
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
