//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDeviceRegistration: Encodable {
    let deviceId: String
    let oldDeviceId: String?
    let userId: String?
    let userName: String?
    let language: String
    let region: String
    let platform: String
    let transport: NotificareTransport
    let osVersion: String
    let sdkVersion: String
    let appVersion: String
    let deviceString: String
    let timeZoneOffset: Float
    let allowedUI: Bool
    let backgroundAppRefresh: Bool

    enum CodingKeys: String, CodingKey {
        case deviceId = "deviceID"
        case oldDeviceId
        case userId = "userID"
        case userName
        case language
        case region
        case platform
        case transport
        case osVersion
        case sdkVersion
        case appVersion
        case deviceString
        case timeZoneOffset
        case allowedUI
        case backgroundAppRefresh
    }
}
