//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

internal class NotificareDatabase: NotificareAbstractDatabase {
    internal init() {
        super.init(name: "NotificareDatabase", rebuildOnVersionChange: true)
    }

    internal func add(_ event: NotificareEvent) {
        ensureLoadedStores()

        _ = event.toManaged(context: context)
        saveChanges()
    }

    internal func remove(_ event: NotificareCoreDataEvent) {
        ensureLoadedStores()

        context.delete(event)
        saveChanges()
    }

    internal func fetchEvents() throws -> [NotificareCoreDataEvent] {
        ensureLoadedStores()

        let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
        let result = try context.fetch(request)

        return result
    }
}
