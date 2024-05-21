//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreLocation
import Foundation
import NotificareKit

public struct NotificareBeacon: Codable, Hashable {
    public let id: String
    public let name: String
    public let major: Int
    public let minor: Int?
    public let triggers: Bool
    public internal(set) var proximity: Proximity = .unknown

    public init(id: String, name: String, major: Int, minor: Int?, triggers: Bool, proximity: NotificareBeacon.Proximity = .unknown) {
        self.id = id
        self.name = name
        self.major = major
        self.minor = minor
        self.triggers = triggers
        self.proximity = proximity
    }

    public enum Proximity: String, Codable {
        case unknown
        case immediate
        case near
        case far
    }
}

// Identifiable: NotificareBeacon
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareBeacon: Identifiable {}

// JSON: NotificareBeacon
extension NotificareBeacon {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareBeacon {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareBeacon.self, from: data)
    }
}
