//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

public struct NotificareVisit: Codable, Equatable {
    public let departureDate: Date
    public let arrivalDate: Date
    public let latitude: Double
    public let longitude: Double

    public init(departureDate: Date, arrivalDate: Date, latitude: Double, longitude: Double) {
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.latitude = latitude
        self.longitude = longitude
    }
}

// JSON: NotificareVisit
extension NotificareVisit {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareVisit {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareVisit.self, from: data)
    }
}
