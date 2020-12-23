//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

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

    // public internal(set) var locationServicesAuthStatus: String?
    // public internal(set) var locationServicesAccuracyAuth: String?
    // public internal(set) var registeredForNotifications: Bool
    // public internal(set) var allowedLocationServices: Bool

//    public struct Location: Codable {
//        public internal(set) var country: String?
//        // public internal(set) var countryCode: String?
//        public internal(set) var latitude: Float?
//        public internal(set) var longitude: Float?
//        public internal(set) var altitude: Float?
//        public internal(set) var accuracy: Float?
//        public internal(set) var floor: Float?
//        public internal(set) var speed: Float?
//        public internal(set) var course: Float?
//
//    }
}

extension NotificareDevice {
    init(from registration: NotificareDeviceRegistration, previous: NotificareDevice?) {
        id = registration.deviceId
        userId = registration.userId
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
