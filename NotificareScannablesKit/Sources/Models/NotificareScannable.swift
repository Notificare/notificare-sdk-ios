//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import NotificareUtilitiesKit

public struct NotificareScannable: Codable, Equatable {
    public let id: String
    public let name: String
    public let tag: String
    public let type: String
    public let notification: NotificareNotification?
}

// Identifiable: NotificareScannable
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareScannable: Identifiable {}

// JSON: NotificareScannable
extension NotificareScannable {
    public func toJson() throws -> [String: Any] {
        let data = try JSONEncoder.notificare.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareScannable {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder.notificare.decode(NotificareScannable.self, from: data)
    }
}
