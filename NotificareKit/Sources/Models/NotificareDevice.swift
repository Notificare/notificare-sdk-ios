//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public typealias NotificareUserData = [String: String]

public struct NotificareDevice: Codable, Equatable {
    public let id: String
    public let userId: String?
    public let userName: String?
    public let timeZoneOffset: Float
    public let dnd: NotificareDoNotDisturb?
    public let userData: NotificareUserData
    public let backgroundAppRefresh: Bool

    public init(id: String, userId: String? = nil, userName: String? = nil, timeZoneOffset: Float, dnd: NotificareDoNotDisturb? = nil, userData: NotificareUserData, backgroundAppRefresh: Bool) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.timeZoneOffset = timeZoneOffset
        self.dnd = dnd
        self.userData = userData
        self.backgroundAppRefresh = backgroundAppRefresh
    }
}

// Identifiable: NotificareDevice
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareDevice: Identifiable {}

// JSON: NotificareDevice
extension NotificareDevice {
    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareDevice {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareDevice.self, from: data)
    }
}
