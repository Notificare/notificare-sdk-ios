//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public struct NotificareDoNotDisturb: Codable {
    public let start: NotificareTime
    public let end: NotificareTime

    public init(start: NotificareTime, end: NotificareTime) {
        self.start = start
        self.end = end
    }
}

// JSON: NotificareDoNotDisturb
public extension NotificareDoNotDisturb {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareDoNotDisturb {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareDoNotDisturb.self, from: data)
    }
}
