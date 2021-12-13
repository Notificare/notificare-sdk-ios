//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUserSegment: Codable {
    public let id: String
    public let name: String
    public let description: String?

    public init(id: String, name: String, description: String?) {
        self.id = id
        self.name = name
        self.description = description
    }
}

// JSON: NotificareUserSegment
public extension NotificareUserSegment {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareUserSegment {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUserSegment.self, from: data)
    }
}
