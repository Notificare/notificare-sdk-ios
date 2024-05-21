//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension NotificareInternals.PushAPI.Payloads {
    internal enum Device {
        internal struct Registration: Encodable {
            internal let deviceID: String
            internal let oldDeviceID: String?
            internal let userID: String?
            internal let userName: String?
            internal let language: String
            internal let region: String
            internal let platform: String
            internal let transport: NotificareTransport
            internal let osVersion: String
            internal let sdkVersion: String
            internal let appVersion: String
            internal let deviceString: String
            internal let timeZoneOffset: Float
            internal let backgroundAppRefresh: Bool
            internal let allowedUI: Bool?
        }

        internal struct UpdateTimeZone: Encodable {
            internal let language: String
            internal let region: String
            internal let timeZoneOffset: Float
        }

        internal struct UpdateLanguage: Encodable {
            internal let language: String
            internal let region: String
        }

        internal struct UpdateBackgroundAppRefresh: Encodable {
            internal let language: String
            internal let region: String
            internal let backgroundAppRefresh: Bool
        }

        internal struct Tags: Encodable {
            internal let tags: [String]
        }
    }

    internal struct CreateEvent: Encodable {}

    internal struct CreateNotificationReply: Encodable {
        internal let notification: String
        internal let deviceID: String
        internal let userID: String?
        internal let label: String
        internal let data: ReplyData

        internal struct ReplyData: Encodable {
            internal let target: String?
            internal let message: String?
            internal let media: String?
            internal let mimeType: String?
        }
    }

    internal struct TestDeviceRegistration: Encodable {
        internal let deviceID: String
    }
}
