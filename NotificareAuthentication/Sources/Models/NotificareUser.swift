//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUser: Codable {
    public let id: String
    public let name: String
    public let pushEmailAddress: String?
    public let segments: [String]
    public let registrationDate: Date
    public let lastActive: Date

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareUser {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUser.self, from: data)
    }
}
