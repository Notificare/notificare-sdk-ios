//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareCore

class NotificareDatabase: NotificareCore.NotificareDatabase {
    init() {
        super.init(name: "NotificareDatabase", rebuildOnVersionChange: true)
    }

    func add(_ event: NotificareEvent) {
        _ = event.toManaged(context: context)
        saveChanges()
    }

    func remove(_ event: NotificareCoreDataEvent) {
        context.delete(event)
        saveChanges()
    }

    func fetchEvents() throws -> [NotificareCoreDataEvent] {
        let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
        let result = try context.fetch(request)

        return result
    }
}
