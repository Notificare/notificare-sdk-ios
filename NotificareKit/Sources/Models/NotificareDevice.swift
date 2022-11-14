//
// Copyright (c) 2020 Notificare. All rights reserved.
//

public typealias NotificareUserData = [String: String]

public struct NotificareDevice: Codable {
    public let id: String
    public internal(set) var userId: String?
    public internal(set) var userName: String?
    public internal(set) var timeZoneOffset: Float
    public internal(set) var osVersion: String
    public internal(set) var sdkVersion: String
    public internal(set) var appVersion: String
    public internal(set) var deviceString: String
    public internal(set) var language: String
    public internal(set) var region: String
    public internal(set) var transport: NotificareTransport
    public internal(set) var dnd: NotificareDoNotDisturb?
    public internal(set) var userData: NotificareUserData
    public internal(set) var lastRegistered: Date
    public internal(set) var backgroundAppRefresh: Bool

    public init(id: String, userId: String? = nil, userName: String? = nil, timeZoneOffset: Float, osVersion: String, sdkVersion: String, appVersion: String, deviceString: String, language: String, region: String, transport: NotificareTransport, dnd: NotificareDoNotDisturb? = nil, userData: NotificareUserData, lastRegistered: Date, backgroundAppRefresh: Bool) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.timeZoneOffset = timeZoneOffset
        self.osVersion = osVersion
        self.sdkVersion = sdkVersion
        self.appVersion = appVersion
        self.deviceString = deviceString
        self.language = language
        self.region = region
        self.transport = transport
        self.dnd = dnd
        self.userData = userData
        self.lastRegistered = lastRegistered
        self.backgroundAppRefresh = backgroundAppRefresh
    }
}

// Identifiable: NotificareDevice
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension NotificareDevice: Identifiable {}

// JSON: NotificareDevice
public extension NotificareDevice {
    func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func fromJson(json: [String: Any]) throws -> NotificareDevice {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareDevice.self, from: data)
    }
}

// Rolling registration
internal extension NotificareDevice {
    init(from registration: NotificareInternals.PushAPI.Payloads.Device.Registration, previous: NotificareDevice?) {
        id = registration.deviceID
        userId = registration.userID
        userName = registration.userName
        timeZoneOffset = registration.timeZoneOffset
        osVersion = registration.osVersion
        sdkVersion = registration.sdkVersion
        appVersion = registration.appVersion
        deviceString = registration.deviceString
        language = registration.language
        region = registration.region
        transport = registration.transport
        dnd = previous?.dnd
        userData = previous?.userData ?? [:]
        lastRegistered = Date()
        backgroundAppRefresh = registration.backgroundAppRefresh
    }
}
