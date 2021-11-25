//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareHeading: Codable {
    public let magneticHeading: Double
    public let trueHeading: Double
    public let headingAccuracy: Double
    public let x: Double
    public let y: Double
    public let z: Double
    public let timestamp: Date
}

// JSON: NotificareHeading
public extension NotificareHeading {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareHeading {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareHeading.self, from: data)
    }
}
