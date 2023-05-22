//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificareMonetizeKit
import OSLog
import SwiftUI

class MonetizeViewModel: ObservableObject {
    @Published private(set) var products = [NotificareProduct]()
    @Published private(set) var purchases = [NotificarePurchase]()

    init() {
        products = Notificare.shared.monetize().products
        purchases = Notificare.shared.monetize().purchases
    }

    func purchase(product: NotificareProduct) {
        Logger.main.info("-----> Purchase \(product.name) clicked <-----")
        Notificare.shared.monetize().startPurchaseFlow(for: product)
    }
}
