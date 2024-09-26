//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

public struct NotificarePushSubscription: Codable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

// JSON: NotificarePushSubscription
extension NotificarePushSubscription {
    public func toJson() throws -> [String: Any] {
        let data = try JSONUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificarePushSubscription {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONUtils.jsonDecoder.decode(NotificarePushSubscription.self, from: data)
    }
}
