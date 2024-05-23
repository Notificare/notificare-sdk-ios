//
// Copyright (c) 2021 Notificare. All rights reserved.
//

public struct NotificareDynamicLink: Codable {
    public let target: String

    public init(target: String) {
        self.target = target
    }
}

// JSON: NotificareDynamicLink
extension NotificareDynamicLink {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareDynamicLink {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareDynamicLink.self, from: data)
    }
}
