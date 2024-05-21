//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import StoreKit

public protocol NotificareMonetizeDelegate: AnyObject {
    func notificare(_ notificareMonetize: NotificareMonetize, didUpdateProducts products: [NotificareProduct])

    func notificare(_ notificareMonetize: NotificareMonetize, didUpdatePurchases purchases: [NotificarePurchase])

    func notificare(_ notificareMonetize: NotificareMonetize, didFinishPurchase purchase: NotificarePurchase)

    func notificare(_ notificareMonetize: NotificareMonetize, didRestorePurchase purchase: NotificarePurchase)

    func notificareDidCancelPurchase(_ notificareMonetize: NotificareMonetize)

    func notificare(_ notificareMonetize: NotificareMonetize, didFailToPurchase error: Error)

    func notificare(_ notificareMonetize: NotificareMonetize, processTransaction transaction: SKPaymentTransaction)
}

extension NotificareMonetizeDelegate {
    public func notificare(_: NotificareMonetize, didUpdateProducts _: [NotificareProduct]) {}

    public func notificare(_: NotificareMonetize, didUpdatePurchases _: [NotificarePurchase]) {}

    public func notificare(_: NotificareMonetize, didFinishPurchase _: NotificarePurchase) {}

    public func notificare(_: NotificareMonetize, didRestorePurchase _: NotificarePurchase) {}

    public func notificareDidCancelPurchase(_: NotificareMonetize) {}

    public func notificare(_: NotificareMonetize, didFailToPurchase _: Error) {}

    public func notificare(_: NotificareMonetize, processTransaction _: SKPaymentTransaction) {}
}
