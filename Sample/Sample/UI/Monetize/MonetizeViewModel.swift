//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import SwiftUI
import NotificareKit
import NotificareMonetizeKit
import OSLog

class MonetizeViewModel: ObservableObject {
    @Published var products = [NotificareProduct]()
    @Published var purchases = [NotificarePurchase]()
    
    init() {
        Logger.main.info("-----> Getting products and purchases <-----")
        products = Notificare.shared.monetize().products
        purchases = Notificare.shared.monetize().purchases
    }
    
    func purchase(product: NotificareProduct) {
        Logger.main.info("-----> Purchase \(product.name) clicked <-----")
        Notificare.shared.monetize().startPurchaseFlow(for: product)
    }
}
