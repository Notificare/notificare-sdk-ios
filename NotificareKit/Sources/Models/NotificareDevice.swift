//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareCore

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
    public internal(set) var userData: NotificareUserData?
    public internal(set) var lastRegistered: Date
    public internal(set) var allowedUI: Bool
    public internal(set) var backgroundAppRefresh: Bool
    public internal(set) var bluetoothEnabled: Bool

    public func toJson() throws -> [String: Any] {
        let data = try NotificareUtils.jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public static func fromJson(json: [String: Any]) throws -> NotificareDevice {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try NotificareUtils.jsonDecoder.decode(NotificareDevice.self, from: data)
    }
}

extension NotificareDevice {
    init(from registration: PushAPI.Payloads.Device.Registration, previous: NotificareDevice?) {
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
        userData = previous?.userData
        lastRegistered = Date()
        allowedUI = registration.allowedUI
        backgroundAppRefresh = registration.backgroundAppRefresh
        bluetoothEnabled = previous?.bluetoothEnabled ?? false
    }
}
