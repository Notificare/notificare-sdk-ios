//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareAsset {
    public let id: String
    public let title: String
    public let description: String?
    public let key: String?
    public let url: String?
    public let button: Button?
    public let metaData: MetaData?
    public let extra: [String: Any]

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareAsset {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareAsset.self, from: data)
    }
}

extension NotificareAsset: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case key
        case url
        case button
        case metaData
        case extra
    }

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
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

public extension NotificareAsset {
    struct Button: Codable {
        public let label: String?
        public let action: String?

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> NotificareAsset.Button {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(NotificareAsset.Button.self, from: data)
        }
    }
}

public extension NotificareAsset {
    struct MetaData: Codable {
        public let originalFileName: String
        public let contentType: String
        public let contentLength: Int

        public func toJson() throws -> [String: Any] {
            let data = try NotificareUtils.jsonEncoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        }

        public static func fromJson(json: [String: Any]) throws -> NotificareAsset.MetaData {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try NotificareUtils.jsonDecoder.decode(NotificareAsset.MetaData.self, from: data)
        }
    }
}

// NotificareAsset.init(PushAPI.Models.Asset)
internal extension NotificareAsset {
    init(asset: NotificareInternals.PushAPI.Models.Asset) {
        id = asset._id
        title = asset.title
        description = asset.description
        key = asset.key

        if let key = asset.key, let host = Notificare.shared.servicesInfo?.services.pushHost {
            url = "\(host)/asset/file/\(key)"
        } else {
            url = nil
        }

        if let button = asset.button {
            self.button = Button(
                label: button.label,
                action: button.action
            )
        } else {
            button = nil
        }

        if let metaData = asset.metaData {
            self.metaData = MetaData(
                originalFileName: metaData.originalFileName,
                contentType: metaData.contentType,
                contentLength: metaData.contentLength
            )
        } else {
            metaData = nil
        }

        extra = asset.extra?.value as? [String: Any] ?? [:]
    }
}
