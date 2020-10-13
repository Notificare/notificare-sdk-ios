//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareDevice {
    public let deviceTokenData: Data
    public let deviceID: String
    public var userID: String?
    public var userName: String?
    public var timezone: Float // timeZoneOffset
    public var osVersion: String
    public var sdkVersion: String
    public var appVersion: String
    public var deviceModel: String
    public var country: String?
    public var countryCode: String?
    public var language: String
    public var region: String
    public var transport: NotificareTransport
    public var dnd: NotificareDoNotDisturb?
    public var userData: [String: Any]?
    public var latitude: Float?
    public var longitude: Float?
    public var altitude: Float?
    public var accuracy: Float?
    public var floor: Float?
    public var speed: Float?
    public var course: Float?
    public var lastRegistered: Date
    public var locationServicesAuthStatus: String?
    public var locationServicesAccuracyAuth: String?
    public var registeredForNotifications: Bool
    public var allowedLocationServices: Bool
    public var allowedUI: Bool
    public var backgroundAppRefresh: Bool
    public var bluetoothON: Bool
}

extension NotificareDevice: Codable {
    enum CodingKeys: CodingKey {
        case deviceTokenData,
            deviceID,
            userID,
            userName,
            timezone,
            osVersion,
            sdkVersion,
            appVersion,
            deviceModel,
            country,
            countryCode,
            language,
            region,
            transport,
            dnd,
            userData,
            latitude,
            longitude,
            altitude,
            accuracy,
            floor,
            speed,
            course,
            lastRegistered,
            locationServicesAuthStatus,
            locationServicesAccuracyAuth,
            registeredForNotifications,
            allowedLocationServices,
            allowedUI,
            backgroundAppRefresh,
            bluetoothON
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        deviceTokenData = try container.decode(Data.self, forKey: .deviceTokenData)
        deviceID = try container.decode(String.self, forKey: .deviceID)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        timezone = try container.decode(Float.self, forKey: .timezone)
        osVersion = try container.decode(String.self, forKey: .osVersion)
        sdkVersion = try container.decode(String.self, forKey: .sdkVersion)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        deviceModel = try container.decode(String.self, forKey: .deviceModel)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        language = try container.decode(String.self, forKey: .language)
        region = try container.decode(String.self, forKey: .region)
        transport = try container.decode(NotificareTransport.self, forKey: .transport)
        dnd = try container.decodeIfPresent(NotificareDoNotDisturb.self, forKey: .dnd)

        if let data = try container.decodeIfPresent(Data.self, forKey: .userData) {
            userData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            userData = nil
        }

        latitude = try container.decodeIfPresent(Float.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Float.self, forKey: .longitude)
        altitude = try container.decodeIfPresent(Float.self, forKey: .altitude)
        accuracy = try container.decodeIfPresent(Float.self, forKey: .accuracy)
        floor = try container.decodeIfPresent(Float.self, forKey: .floor)
        speed = try container.decodeIfPresent(Float.self, forKey: .speed)
        course = try container.decodeIfPresent(Float.self, forKey: .course)
        lastRegistered = try container.decode(Date.self, forKey: .lastRegistered)
        locationServicesAuthStatus = try container.decodeIfPresent(String.self, forKey: .locationServicesAuthStatus)
        locationServicesAccuracyAuth = try container.decodeIfPresent(String.self, forKey: .locationServicesAccuracyAuth)
        registeredForNotifications = try container.decode(Bool.self, forKey: .registeredForNotifications)
        allowedLocationServices = try container.decode(Bool.self, forKey: .allowedLocationServices)
        allowedUI = try container.decode(Bool.self, forKey: .allowedUI)
        backgroundAppRefresh = try container.decode(Bool.self, forKey: .backgroundAppRefresh)
        bluetoothON = try container.decode(Bool.self, forKey: .bluetoothON)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(deviceTokenData, forKey: .deviceTokenData)
        try container.encode(deviceID, forKey: .deviceID)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(userName, forKey: .userName)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(osVersion, forKey: .osVersion)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encode(language, forKey: .language)
        try container.encode(region, forKey: .region)
        try container.encode(transport, forKey: .transport)
        try container.encodeIfPresent(dnd, forKey: .dnd)

        if let userData = self.userData,
            let data = try? JSONSerialization.data(withJSONObject: userData, options: [])
        {
            try container.encode(data, forKey: .userData)
        }

        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(altitude, forKey: .altitude)
        try container.encodeIfPresent(accuracy, forKey: .accuracy)
        try container.encodeIfPresent(floor, forKey: .floor)
        try container.encodeIfPresent(speed, forKey: .speed)
        try container.encodeIfPresent(course, forKey: .course)
        try container.encode(lastRegistered, forKey: .lastRegistered)
        try container.encodeIfPresent(locationServicesAuthStatus, forKey: .locationServicesAuthStatus)
        try container.encodeIfPresent(locationServicesAccuracyAuth, forKey: .locationServicesAccuracyAuth)
        try container.encode(registeredForNotifications, forKey: .registeredForNotifications)
        try container.encode(allowedLocationServices, forKey: .allowedLocationServices)
        try container.encode(allowedUI, forKey: .allowedUI)
        try container.encode(backgroundAppRefresh, forKey: .backgroundAppRefresh)
        try container.encode(bluetoothON, forKey: .bluetoothON)
    }
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
