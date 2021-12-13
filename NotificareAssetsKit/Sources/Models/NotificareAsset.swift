//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareAsset: Codable {
    public let id: String
    public let title: String
    public let description: String?
    public let key: String?
    public let url: String?
    public let button: Button?
    public let metaData: MetaData?
    public let extra: [String: Any]

    public init(id: String, title: String, description: String?, key: String?, url: String?, button: NotificareAsset.Button?, metaData: NotificareAsset.MetaData?, extra: [String: Any]) {
        self.id = id
        self.title = title
        self.description = description
        self.key = key
        self.url = url
        self.button = button
        self.metaData = metaData
        self.extra = extra
    }

    public struct Button: Codable {
        public let label: String?
        public let action: String?

        public init(label: String?, action: String?) {
            self.label = label
            self.action = action
        }
    }

    public struct MetaData: Codable {
        public let originalFileName: String
        public let contentType: String
        public let contentLength: Int

        public init(originalFileName: String, contentType: String, contentLength: Int) {
            self.originalFileName = originalFileName
            self.contentType = contentType
            self.contentLength = contentLength
        }
    }
}

// JSON: NotificareAsset
public extension NotificareAsset {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareAsset {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareAsset.self, from: data)
    }
}

// Codable: NotificareAsset
public extension NotificareAsset {
    internal enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case key
        case url
        case button
        case metaData
        case extra
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        button = try container.decodeIfPresent(Button.self, forKey: .button)
        metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData)

        if let extra = try container.decodeIfPresent(AnyCodable.self, forKey: .extra) {
            self.extra = extra.value as! [String: Any]
        } else {
            extra = [:]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(key, forKey: .key)
        try container.encode(url, forKey: .url)
        try container.encode(button, forKey: .button)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(AnyCodable(extra), forKey: .extra)
    }
}

// JSON: NotificareAsset.Button
public extension NotificareAsset.Button {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareAsset.Button {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareAsset.Button.self, from: data)
    }
}

// JSON: NotificareAsset.MetaData
public extension NotificareAsset.MetaData {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareAsset.MetaData {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareAsset.MetaData.self, from: data)
    }
}
