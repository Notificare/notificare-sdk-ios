//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareScannable: Codable {
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
public extension NotificareScannable {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareScannable {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareScannable.self, from: data)
    }
}
