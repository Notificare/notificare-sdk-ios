//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Pass: Decodable {
        let _id: String
        let version: Int
        let passbook: String?
        let template: String?
        let serial: String
        let barcode: String
        let redeem: NotificarePass.Redeem
        let redeemHistory: [NotificarePass.Redemption]
        let limit: Int
        let token: String
        let data: AnyCodable?
        let date: Date
    }

    struct Passbook: Decodable {
        let passStyle: NotificarePass.PassType
    }
}
