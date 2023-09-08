//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

class NotificareDatabase: NotificareAbstractDatabase {
    init() {
        super.init(name: "NotificareDatabase", rebuildOnVersionChange: true)
    }

    func add(_ event: NotificareEvent) {
        ensureLoadedStores()

        _ = event.toManaged(context: context)
        saveChanges()
    }

    func remove(_ event: NotificareCoreDataEvent) {
        ensureLoadedStores()

        context.delete(event)
        saveChanges()
    }

    func fetchEvents() throws -> [NotificareCoreDataEvent] {
        ensureLoadedStores()

        let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
        let result = try context.fetch(request)

        return result
    }
}
