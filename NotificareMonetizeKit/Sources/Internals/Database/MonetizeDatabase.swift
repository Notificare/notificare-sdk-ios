//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareKit

internal class MonetizeDatabase: NotificareAbstractDatabase {
    internal init() {
        super.init(
            name: "NotificareMonetizeDatabase",
            rebuildOnVersionChange: true,
            mergePolicy: .overwrite
        )
    }

    internal func add(_ purchase: NotificarePurchase) throws -> PurchaseEntity {
        ensureLoadedStores()

        let entity = try PurchaseEntity(context, purchase: purchase)
        saveChanges()

        return entity
    }

    internal func find() throws -> [PurchaseEntity] {
        ensureLoadedStores()

        let request = NSFetchRequest<PurchaseEntity>(entityName: "PurchaseEntity")
        let result = try context.fetch(request)

        return result
    }

    internal func clear() throws {
        ensureLoadedStores()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PurchaseEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
    }
}
