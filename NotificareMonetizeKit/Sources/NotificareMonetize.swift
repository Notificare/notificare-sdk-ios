//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareMonetize: AnyObject {
    // MARK: Properties

    var delegate: NotificareMonetizeDelegate? { get }

    var hasPurchasingCapabilitiesAvailable: Bool { get }

    var products: [NotificareProduct] { get }

    var purchases: [NotificarePurchase] { get }

    // MARK: Methods

    func refresh(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func refresh() async throws

    func startPurchaseFlow(for product: NotificareProduct)
}
