//
// Copyright (c) 2021 Notificare. All rights reserved.
//
import NotificareUtilitiesKit

public struct NotificareDynamicLink: Codable, Equatable {
    public let target: String

    public init(target: String) {
        self.target = target
    }
}

// JSON: NotificareDynamicLink
extension NotificareDynamicLink {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareDynamicLink {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificareDynamicLink.self, from: data)
    }
}
