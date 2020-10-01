//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public typealias NotificareEventData = [String: JSONValue]

public struct NotificareEvent {
    public let type: String
    public let timestamp: Int64
    public let deviceId: String
    public let sessionId: String?
    public let notificationId: String?
    public let userId: String?
    public let data: NotificareEventData?
}

// MARK: - Codable

extension NotificareEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case timestamp
        case deviceId = "deviceID"
        case sessionId = "sessionID"
        case notificationId = "notification"
        case userId = "userID"
        case data
    }
}
