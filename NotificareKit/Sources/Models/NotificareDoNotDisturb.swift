//
// Copyright (c) 2020 Notificare. All rights reserved.
//
import NotificareUtilitiesKit

public struct NotificareDoNotDisturb: Codable, Equatable {
    public let start: NotificareTime
    public let end: NotificareTime

    public init(start: NotificareTime, end: NotificareTime) {
        self.start = start
        self.end = end
    }
}

// JSON: NotificareDoNotDisturb
extension NotificareDoNotDisturb {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.notificare.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareDoNotDisturb {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.notificare.decode(NotificareDoNotDisturb.self, from: data)
    }
}
