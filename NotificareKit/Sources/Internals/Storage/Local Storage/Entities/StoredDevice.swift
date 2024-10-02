//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

internal struct StoredDevice: Codable {
    internal let id: String
    internal var userId: String?
    internal var userName: String?
    internal var timeZoneOffset: Float
    internal var osVersion: String
    internal var sdkVersion: String
    internal var appVersion: String
    internal var deviceString: String
    internal var language: String
    internal var region: String
    internal var transport: String? = nil
    internal var dnd: NotificareDoNotDisturb?
    internal var userData: NotificareUserData
    internal var backgroundAppRefresh: Bool

    internal var isLongLived: Bool {
        transport == nil
    }
}

extension StoredDevice {
    internal func asPublic() -> NotificareDevice {
        NotificareDevice(
            id: id,
            userId: userId,
            userName: userName,
            timeZoneOffset: timeZoneOffset,
            dnd: dnd,
            userData: userData,
            backgroundAppRefresh: backgroundAppRefresh
        )
    }
}
