//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificareMonetizeKit
import OSLog
import SwiftUI

internal class MonetizeViewModel: ObservableObject {
    @Published internal private(set) var products = [NotificareProduct]()
    @Published internal private(set) var purchases = [NotificarePurchase]()

    internal init() {
        products = Notificare.shared.monetize().products
        purchases = Notificare.shared.monetize().purchases
    }

    internal func purchase(product: NotificareProduct) {
        Logger.main.info("Purchase \(product.name) clicked")
        Notificare.shared.monetize().startPurchaseFlow(for: product)
    }
}
