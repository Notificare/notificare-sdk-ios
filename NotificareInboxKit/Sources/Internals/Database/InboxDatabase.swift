//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareCore

class InboxDatabase: NotificareCore.NotificareDatabase {
    init() {
        super.init(name: "NotificareInboxDataModel", rebuildOnVersionChange: true)
    }

    func add(_ item: NotificareInboxItem) -> InboxItemEntity {
        let entity = InboxItemEntity(from: item, context: context)
        saveChanges()

        return entity
    }

    func find() throws -> [InboxItemEntity] {
        let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
        let result = try context.fetch(request)

        return result
    }

    func find(id: String) throws -> [InboxItemEntity] {
        let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
        request.predicate = NSPredicate(format: "id = %@", id)

        let result = try context.fetch(request)

        return result
    }

    func findDuplicates(of notificationId: String) throws -> [InboxItemEntity] {
        let request = NSFetchRequest<InboxItemEntity>(entityName: "InboxItemEntity")
        request.predicate = NSPredicate(format: "notificationId = %@", notificationId)

        let result = try context.fetch(request)

        return result
    }

    func remove(_ item: InboxItemEntity) {
        context.delete(item)
        saveChanges()
    }

    func clear() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InboxItemEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
    }
}