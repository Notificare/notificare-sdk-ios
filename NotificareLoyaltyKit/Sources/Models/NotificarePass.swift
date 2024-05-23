//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificarePass: Codable {
    public let id: String
    public let type: PassType?
    public let version: Int
    public let passbook: String?
    public let template: String?
    public let serial: String
    public let barcode: String
    public let redeem: Redeem
    public let redeemHistory: [Redemption]
    public let limit: Int
    public let token: String
    public let data: [String: Any]
    public let date: Date
    // public let googlePaySaveLink: String?

    public init(id: String, type: NotificarePass.PassType?, version: Int, passbook: String?, template: String?, serial: String, barcode: String, redeem: NotificarePass.Redeem, redeemHistory: [NotificarePass.Redemption], limit: Int, token: String, data: [String: Any], date: Date) {
        self.id = id
        self.type = type
        self.version = version
        self.passbook = passbook
        self.template = template
        self.serial = serial
        self.barcode = barcode
        self.redeem = redeem
        self.redeemHistory = redeemHistory
        self.limit = limit
        self.token = token
        self.data = data
        self.date = date
    }

    public enum PassType: String, Codable {
        case boarding
        case coupon
        case ticket
        case generic
        case card
    }

    public enum Redeem: String, Codable {
        case once
        case limit
        case always
    }

    public struct Redemption: Codable {
        public let comments: String?
        public let date: Date

        public init(comments: String?, date: Date) {
            self.comments = comments
            self.date = date
        }
    }
}

// Identifiable: NotificarePass
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificarePass: Identifiable {}

// JSON: NotificarePass
extension NotificarePass {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificarePass {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificarePass.self, from: data)
    }
}

// Codable: NotificarePass
extension NotificarePass {
    internal enum CodingKeys: String, CodingKey {
        case id
        case type
        case version
        case passbook
        case template
        case serial
        case barcode
        case redeem
        case redeemHistory
        case limit
        case token
        case data
        case date
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(PassType.self, forKey: .type)
        version = try container.decode(Int.self, forKey: .version)
        passbook = try container.decodeIfPresent(String.self, forKey: .passbook)
        template = try container.decodeIfPresent(String.self, forKey: .template)
        serial = try container.decode(String.self, forKey: .serial)
        barcode = try container.decode(String.self, forKey: .barcode)
        redeem = try container.decode(Redeem.self, forKey: .redeem)
        redeemHistory = try container.decode([Redemption].self, forKey: .redeemHistory)
        limit = try container.decode(Int.self, forKey: .limit)
        token = try container.decode(String.self, forKey: .token)
        data = try container.decodeIfPresent(NotificareAnyCodable.self, forKey: .token)?.value as? [String: Any] ?? [:]
        date = try container.decode(Date.self, forKey: .date)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(passbook, forKey: .passbook)
        try container.encodeIfPresent(template, forKey: .template)
        try container.encode(serial, forKey: .serial)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(redeem, forKey: .redeem)
        try container.encode(redeemHistory, forKey: .redeemHistory)
        try container.encode(limit, forKey: .limit)
        try container.encode(token, forKey: .token)
        try container.encode(NotificareAnyCodable(data), forKey: .data)
        try container.encode(date, forKey: .date)
    }
}

// JSON: NotificarePass.Redemption
extension NotificarePass.Redemption {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificarePass.Redemption {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificarePass.Redemption.self, from: data)
    }
}
