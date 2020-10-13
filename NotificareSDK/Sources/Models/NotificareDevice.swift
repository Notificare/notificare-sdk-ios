//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public typealias NotificareUserData = [String: String]

public struct NotificareDevice: Codable {
    public let deviceTokenData: Data
    public let deviceID: String
    public internal(set) var userID: String?
    public internal(set) var userName: String?
    public internal(set) var timezone: Float // timeZoneOffset
    public internal(set) var osVersion: String
    public internal(set) var sdkVersion: String
    public internal(set) var appVersion: String
    public internal(set) var deviceModel: String
    public internal(set) var country: String?
    public internal(set) var countryCode: String?
    public internal(set) var language: String
    public internal(set) var region: String
    public internal(set) var transport: NotificareTransport
    public internal(set) var dnd: NotificareDoNotDisturb?
    public internal(set) var userData: NotificareUserData?
    public internal(set) var latitude: Float?
    public internal(set) var longitude: Float?
    public internal(set) var altitude: Float?
    public internal(set) var accuracy: Float?
    public internal(set) var floor: Float?
    public internal(set) var speed: Float?
    public internal(set) var course: Float?
    public internal(set) var lastRegistered: Date
    public internal(set) var locationServicesAuthStatus: String?
    public internal(set) var locationServicesAccuracyAuth: String?
    public internal(set) var registeredForNotifications: Bool
    public internal(set) var allowedLocationServices: Bool
    public internal(set) var allowedUI: Bool
    public internal(set) var backgroundAppRefresh: Bool
    public internal(set) var bluetoothON: Bool
}

extension NotificareDevice {
    init(from registration: NotificareDeviceRegistration, with tokenData: Data) {
        deviceTokenData = tokenData
        deviceID = registration.deviceId
        userID = registration.userId
        userName = registration.userName
        timezone = registration.timeZoneOffset
        osVersion = registration.osVersion
        sdkVersion = registration.sdkVersion
        appVersion = registration.appVersion
        deviceModel = registration.deviceString
        country = nil
        countryCode = nil
        language = registration.language
        region = registration.region
        transport = registration.transport
        dnd = nil
        userData = nil
        latitude = nil
        longitude = nil
        altitude = nil
        accuracy = nil
        floor = nil
        speed = nil
        course = nil
        lastRegistered = Date()
        locationServicesAuthStatus = nil
        locationServicesAccuracyAuth = nil
        registeredForNotifications = false
        allowedLocationServices = false
        allowedUI = false
        backgroundAppRefresh = registration.backgroundAppRefresh
        bluetoothON = false
    }
}
