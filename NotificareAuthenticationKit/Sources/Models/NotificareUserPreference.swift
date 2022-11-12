//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public struct NotificareUserPreference: Codable, Identifiable {
    public let id: String
    public let label: String
    public let type: PreferenceType
    public let options: [Option]
    public let position: Int

    public init(id: String, label: String, type: NotificareUserPreference.PreferenceType, options: [NotificareUserPreference.Option], position: Int) {
        self.id = id
        self.label = label
        self.type = type
        self.options = options
        self.position = position
    }

    public enum PreferenceType: String, Codable {
        case single
        case choice
        case select
    }

    public struct Option: Codable {
        public let label: String
        public let segmentId: String
        public let selected: Bool

        public init(label: String, segmentId: String, selected: Bool) {
            self.label = label
            self.segmentId = segmentId
            self.selected = selected
        }
    }
}

// JSON: NotificareUserPreference
public extension NotificareUserPreference {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareUserPreference {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUserPreference.self, from: data)
    }
}

// JSON: NotificareUserPreference.Option
public extension NotificareUserPreference.Option {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareUserPreference.Option {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareUserPreference.Option.self, from: data)
    }
}
