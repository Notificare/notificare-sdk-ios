//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import CoreData
import NotificareKit

internal extension PurchaseEntity {
    convenience init(_ context: NSManagedObjectContext, purchase: NotificarePurchase) throws {
        guard let receiptData = purchase.receipt.data(using: .utf8) else {
            throw MonetizeDatabaseError.corruptedReceipt
        }

        let purchaseData = try NotificareUtils.jsonEncoder.encode(purchase)

        self.init(context: context)
        id = purchase.id
        productIdentifier = purchase.productIdentifier
        time = purchase.time
        receipt = receiptData
        self.purchase = purchaseData
    }

    func toModel() throws -> NotificarePurchase {
        guard let data = purchase else {
            throw MonetizeDatabaseError.corruptedPurchase
        }

        return try NotificareUtils.jsonDecoder.decode(NotificarePurchase.self, from: data)
    }
}
