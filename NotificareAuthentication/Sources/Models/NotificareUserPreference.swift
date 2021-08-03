//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUserPreference: Codable {
    public let id: String
    public let label: String
    public let type: `Type`
    public let options: [Option]
    public let position: Int

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareUser {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUser.self, from: data)
    }
}

public extension NotificareUserPreference {
    enum `Type`: String, Codable {
        case single
        case choice
        case select
    }
}

public extension NotificareUserPreference {
    struct Option: Codable {
        public let label: String
        public let segmentId: String
        public let selected: Bool

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> Option {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(Option.self, from: data)
        }
    }
}
