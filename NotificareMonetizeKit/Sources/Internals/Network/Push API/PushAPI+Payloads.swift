//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Payloads {
    internal struct PurchaseVerification: Encodable {
        internal let receipt: String
        internal let price: Double
        internal let currency: String
    }
}
