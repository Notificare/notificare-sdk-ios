//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import StoreKit

internal extension NotificareProduct {
    init(ncProduct: NotificareInternals.PushAPI.Models.Product, skProduct: SKProduct?) {
        id = ncProduct._id
        identifier = ncProduct.identifier
        name = ncProduct.name
        type = ncProduct.type
        storeDetails = skProduct.map {
            NotificareProduct.StoreDetails(
                title: $0.localizedTitle,
                description: $0.localizedDescription,
                price: $0.price.doubleValue,
                currencyCode: $0.priceLocale.currencyCode ?? "EUR"
            )
        }
    }
}

internal extension Sequence {
    func associateBy<Key>(_ keySelector: @escaping (Element) -> Key) -> [Key: Element] {
        Dictionary(
            map { element in
                let key = keySelector(element)
                return (key, element)
            },
            uniquingKeysWith: ({ _, second in
                second
            })
        )
    }

    func compactAssociateBy<Key>(_ keySelector: @escaping (Element) -> Key?) -> [Key: Element] {
        Dictionary(
            compactMap { element in
                guard let key = keySelector(element) else { return nil }
                return (key, element)
            },
            uniquingKeysWith: ({ _, second in
                second
            })
        )
    }
}
