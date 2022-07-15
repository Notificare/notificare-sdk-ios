//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareProduct: Codable {
    public let id: String
    public let identifier: String
    public let name: String
    public let type: String
    public let storeDetails: StoreDetails?

    public init(id: String, identifier: String, name: String, type: String, storeDetails: NotificareProduct.StoreDetails?) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.type = type
        self.storeDetails = storeDetails
    }

    public struct StoreDetails: Codable {
        // public let name: String
        public let title: String
        public let description: String
        public let price: Double
        public let currencyCode: String

        public init(title: String, description: String, price: Double, currencyCode: String) {
            self.title = title
            self.description = description
            self.price = price
            self.currencyCode = currencyCode
        }
    }
}

// JSON: NotificareProduct
public extension NotificareProduct {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareProduct {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareProduct.self, from: data)
    }
}

// JSON: NotificareProduct.StoreDetails
public extension NotificareProduct.StoreDetails {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareProduct.StoreDetails {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareProduct.StoreDetails.self, from: data)
    }
}
