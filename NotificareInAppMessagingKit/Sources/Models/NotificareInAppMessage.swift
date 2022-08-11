//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

public struct NotificareInAppMessage: Codable {
    public let id: String
    public let name: String
    public let type: String
    public let context: [String]
    public let title: String?
    public let message: String?
    public let image: String?
    public let landscapeImage: String?
    public let delaySeconds: Int
    public let primaryAction: Action?
    public let secondaryAction: Action?
    
    public init(id: String, name: String, type: String, context: [String], title: String?, message: String?, image: String?, landscapeImage: String?, delaySeconds: Int, primaryAction: NotificareInAppMessage.Action?, secondaryAction: NotificareInAppMessage.Action?) {
        self.id = id
        self.name = name
        self.type = type
        self.context = context
        self.title = title
        self.message = message
        self.image = image
        self.landscapeImage = landscapeImage
        self.delaySeconds = delaySeconds
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    public struct Action: Codable {
        public let label: String?
        public let destructive: Bool
        public let url: String?
        
        public init(label: String?, destructive: Bool, url: String?) {
            self.label = label
            self.destructive = destructive
            self.url = url
        }
    }
    
    public enum ActionType: String {
        case primary
        case secondary
    }
}

// JSON: NotificareInAppMessage
public extension NotificareInAppMessage {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareInAppMessage {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareInAppMessage.self, from: data)
    }
}

// JSON: NotificareInAppMessage.Action
public extension NotificareInAppMessage.Action {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareInAppMessage.Action {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareInAppMessage.Action.self, from: data)
    }
}
