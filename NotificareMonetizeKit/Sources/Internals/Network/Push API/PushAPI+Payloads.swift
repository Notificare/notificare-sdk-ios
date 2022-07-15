//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Payloads {
    struct PurchaseVerification: Encodable {
        let receipt: String
        let price: Double
        let currency: String
    }
}
