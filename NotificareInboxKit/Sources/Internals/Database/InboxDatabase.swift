//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareKit

class InboxDatabase: NotificareAbstractDatabase {
    init() {
        super.init(
            name: "NotificareInboxDatabase",
            rebuildOnVersionChange: true,
            mergePolicy: .overwrite
        )
    }

    func add(_ item: NotificareInboxItem, visible: Bool) throws -> InboxItemEntity {
        ensureLoadedStores()

        let entity = try InboxItemEntity(from: item, visible: visible, context: context)
        saveChanges()

        return entity
    }

    func find() throws -> [InboxItemEntity] {
        ensureLoadedStores()

        let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
        let result = try context.fetch(request)

        return result
    }

    func find(id: String) throws -> [InboxItemEntity] {
        ensureLoadedStores()

        let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
        request.predicate = NSPredicate(format: "id = %@", id)

        let result = try context.fetch(request)

        return result
    }

    func remove(_ item: InboxItemEntity) {
        ensureLoadedStores()

        context.delete(item)
        saveChanges()
    }

    func clear() throws {
        ensureLoadedStores()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
    }
}
