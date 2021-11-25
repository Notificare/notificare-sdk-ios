//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareVisit: Codable {
    public let departureDate: Date
    public let arrivalDate: Date
    public let latitude: Double
    public let longitude: Double
}

// JSON: NotificareVisit
public extension NotificareVisit {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareVisit {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareVisit.self, from: data)
    }
}
