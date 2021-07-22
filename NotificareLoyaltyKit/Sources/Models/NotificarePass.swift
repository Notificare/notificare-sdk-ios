//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificarePass {
    public let id: String
    public let active: Bool
    public let passbook: String
    public let barcode: String
    public let serial: String
    public let redeem: Redeem
    public let limit: Int
    public let token: String
    public let data: [String: Any]
    public let date: Date
    public let redeemHistory: [Redemption]

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificarePass {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificarePass.self, from: data)
    }
}

extension NotificarePass: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case active
        case passbook
        case barcode
        case serial
        case redeem
        case limit
        case token
        case data
        case date
        case redeemHistory
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        active = try container.decode(Bool.self, forKey: .active)
        passbook = try container.decode(String.self, forKey: .passbook)
        barcode = try container.decode(String.self, forKey: .barcode)
        serial = try container.decode(String.self, forKey: .serial)
        redeem = try container.decode(Redeem.self, forKey: .redeem)
        limit = try container.decode(Int.self, forKey: .limit)
        token = try container.decode(String.self, forKey: .token)
        data = try container.decodeIfPresent(AnyCodable.self, forKey: .token)?.value as? [String: Any] ?? [:]
        date = try container.decode(Date.self, forKey: .date)
        redeemHistory = try container.decode([Redemption].self, forKey: .redeemHistory)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(active, forKey: .active)
        try container.encode(passbook, forKey: .passbook)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(serial, forKey: .serial)
        try container.encode(redeem, forKey: .redeem)
        try container.encode(limit, forKey: .limit)
        try container.encode(token, forKey: .token)
        try container.encode(AnyCodable(data), forKey: .data)
        try container.encode(date, forKey: .date)
        try container.encode(redeemHistory, forKey: .redeemHistory)
    }
}

public extension NotificarePass {
    enum Redeem: String, Codable {
        case once
        case limit
        case always

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            self = Redeem(rawValue: value) ?? .always
        }
    }
}

public extension NotificarePass {
    struct Redemption: Codable {
        public let comments: String?
        public let date: Date

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Redemption {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Redemption.self, from: data)
        }
    }
}
