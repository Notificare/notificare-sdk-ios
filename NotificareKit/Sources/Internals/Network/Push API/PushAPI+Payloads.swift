//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension NotificareInternals.PushAPI.Payloads {
    enum Device {
        struct Registration: Encodable {
            let deviceID: String
            let oldDeviceID: String?
            let userID: String?
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
            let backgroundAppRefresh: Bool
            let allowedUI: Bool?

            enum CodingKeys: String, CodingKey {
                case deviceID
                case oldDeviceID
                case userID
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
                case backgroundAppRefresh
                case allowedUI
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(self.deviceID, forKey: .deviceID)
                try container.encodeIfPresent(self.oldDeviceID, forKey: .oldDeviceID)
                try container.encode(self.userID, forKey: .userID)
                try container.encode(self.userName, forKey: .userName)
                try container.encode(self.language, forKey: .language)
                try container.encode(self.region, forKey: .region)
                try container.encode(self.platform, forKey: .platform)
                try container.encode(self.transport, forKey: .transport)
                try container.encode(self.osVersion, forKey: .osVersion)
                try container.encode(self.sdkVersion, forKey: .sdkVersion)
                try container.encode(self.appVersion, forKey: .appVersion)
                try container.encode(self.deviceString, forKey: .deviceString)
                try container.encode(self.timeZoneOffset, forKey: .timeZoneOffset)
                try container.encode(self.backgroundAppRefresh, forKey: .backgroundAppRefresh)
                try container.encodeIfPresent(self.allowedUI, forKey: .allowedUI)
            }
        }

        struct UpdateTimeZone: Encodable {
            let language: String
            let region: String
            let timeZoneOffset: Float
        }

        struct UpdateLanguage: Encodable {
            let language: String
            let region: String
        }

        struct UpdateBackgroundAppRefresh: Encodable {
            let language: String
            let region: String
            let backgroundAppRefresh: Bool
        }

        struct Tags: Encodable {
            let tags: [String]
        }
    }

    struct CreateEvent: Encodable {}

    struct CreateNotificationReply: Encodable {
        let notification: String
        let deviceID: String
        let userID: String?
        let label: String
        let data: ReplyData

        struct ReplyData: Encodable {
            let target: String?
            let message: String?
            let media: String?
            let mimeType: String?
        }
    }

    struct TestDeviceRegistration: Encodable {
        let deviceID: String
    }
}
