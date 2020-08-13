//
// Created by Helder Pinhal on 07/08/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceRegistration: Encodable {
    let deviceId: String
    let oldDeviceId: String?
    let userId: String?
    let userName: String?
    let country: String?
    let language: String
    let region: String
    let platform: String
    let transport: NotificareTransport
    let osVersion: String
    let sdkVersion: String
    let appVersion: String
    let deviceString: String
    let timeZoneOffset: Float
    let backgroundAppRefresh: Bool


    enum CodingKeys: String, CodingKey {
        case deviceId = "deviceID"
        case oldDeviceId
        case userId = "userID"
        case userName
        case country
        case language
        case region
        case platform
        case transport
        case osVersion
        case sdkVersion
        case appVersion
        case deviceString
        case timeZoneOffset
        case backgroundAppRefresh
    }
}

extension NotificareDeviceRegistration {
    func toStoredDevice(with tokenData: Data) -> NotificareDevice {
        NotificareDevice(
            deviceTokenData: tokenData,
            deviceID: self.deviceId,
            userID: self.userId,
            userName: self.userName,
            timezone: self.timeZoneOffset,
            osVersion: self.osVersion,
            sdkVersion: self.sdkVersion,
            appVersion: self.appVersion,
            deviceModel: self.deviceString,
            country: nil,
            countryCode: nil,
            language: self.language,
            region: self.region,
            transport: self.transport,
            dnd: nil,
            userData: nil,
            latitude: nil,
            longitude: nil,
            altitude: nil,
            accuracy: nil,
            floor: nil,
            speed: nil,
            course: nil,
            lastRegistered: Date(),
            locationServicesAuthStatus: nil,
            locationServicesAccuracyAuth: nil,
            registeredForNotifications: false,
            allowedLocationServices: false,
            allowedUI: false,
            backgroundAppRefresh: self.backgroundAppRefresh,
            bluetoothON: false
        )
    }
}
