//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Models {
    internal struct Pass: Decodable {
        internal let _id: String
        internal let version: Int
        internal let passbook: String?
        internal let template: String?
        internal let serial: String
        internal let barcode: String
        internal let redeem: NotificarePass.Redeem
        internal let redeemHistory: [NotificarePass.Redemption]
        internal let limit: Int
        internal let token: String
        internal let data: NotificareAnyCodable?
        internal let date: Date
    }

    internal struct Passbook: Decodable {
        internal let passStyle: NotificarePass.PassType
    }
}
