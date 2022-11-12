//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificarePurchase: Codable, Identifiable {
    public let id: String
    public let productIdentifier: String
    public let time: Date
    public let receipt: String

    public init(id: String, productIdentifier: String, time: Date, receipt: String) {
        self.id = id
        self.productIdentifier = productIdentifier
        self.time = time
        self.receipt = receipt
    }
}

// JSON: NotificarePurchase
public extension NotificarePurchase {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificarePurchase {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificarePurchase.self, from: data)
    }
}
