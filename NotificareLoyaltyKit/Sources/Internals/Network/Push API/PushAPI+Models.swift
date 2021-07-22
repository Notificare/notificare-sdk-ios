//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Pass: Decodable {
        let _id: String
        let active: Bool
        let passbook: String
        let barcode: String
        let serial: String
        let redeem: String
        let limit: Int
        let token: String
        let data: AnyCodable?
        let date: Date
        let redeemHistory: [NotificarePass.Redemption]

        func toModel() -> NotificarePass {
            NotificarePass(
                id: _id,
                active: active,
                passbook: passbook,
                barcode: barcode,
                serial: serial,
                redeem: NotificarePass.Redeem(rawValue: redeem) ?? .always,
                limit: limit,
                token: token,
                data: data?.value as? [String: Any] ?? [:],
                date: date,
                redeemHistory: redeemHistory
            )
        }
    }
}
