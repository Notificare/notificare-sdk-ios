//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import CoreData
import Foundation
import NotificareKit

internal class MonetizeDatabase: NotificareAbstractDatabase {
    init() {
        super.init(name: "NotificareMonetizeDatabase", rebuildOnVersionChange: true)
        context.mergePolicy = NSOverwriteMergePolicy
    }

    internal func add(_ purchase: NotificarePurchase) throws -> PurchaseEntity {
        let entity = try PurchaseEntity(context, purchase: purchase)
        saveChanges()

        return entity
    }

    internal func find() throws -> [PurchaseEntity] {
        let request = NSFetchRequest<PurchaseEntity>(entityName: "PurchaseEntity")
        let result = try context.fetch(request)

        return result
    }
}
