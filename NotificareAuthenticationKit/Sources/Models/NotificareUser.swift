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

    public init(id: String, name: String, pushEmailAddress: String?, segments: [String], registrationDate: Date, lastActive: Date) {
        self.id = id
        self.name = name
        self.pushEmailAddress = pushEmailAddress
        self.segments = segments
        self.registrationDate = registrationDate
        self.lastActive = lastActive
    }
}

// Identifiable: NotificareUser
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareUser: Identifiable {}

// JSON: NotificareUser
public extension NotificareUser {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareUser {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUser.self, from: data)
    }
}
