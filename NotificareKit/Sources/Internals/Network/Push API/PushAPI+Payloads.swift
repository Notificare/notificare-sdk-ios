//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Payloads {
    enum Device {
        struct Registration: Encodable {
            let deviceID: String
            let oldDeviceId: String?
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
            let allowedUI: Bool
            let backgroundAppRefresh: Bool
        }

        struct UpdateNotificationSettings: Encodable {
            let language: String
            let region: String
            let allowedUI: Bool
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
