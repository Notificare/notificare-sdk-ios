//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

extension NotificareInternals.PushAPI.Payloads {
    internal struct CreateDevice: Encodable {
        internal var language: String
        internal var region: String
        internal var platform: String
        internal var osVersion: String
        internal var sdkVersion: String
        internal var appVersion: String
        internal var deviceString: String
        internal var timeZoneOffset: Float
        internal var backgroundAppRefresh: Bool
    }

    internal struct UpdateDevice: Encodable {
        internal var language: String
        internal var region: String
        internal var platform: String
        internal var osVersion: String
        internal var sdkVersion: String
        internal var appVersion: String
        internal var deviceString: String
        internal var timeZoneOffset: Float
        internal var backgroundAppRefresh: Bool
    }

    internal struct UpdateDeviceUser: Encodable {
        @EncodeNull internal var userID: String?
        @EncodeNull internal var userName: String?
    }

    internal struct UpdateDeviceDoNotDisturb: Encodable {
        @EncodeNull internal var dnd: NotificareDoNotDisturb?
    }

    internal struct UpdateDeviceUserData: Encodable {
        internal let userData: [String: String?]
    }

    internal struct UpgradeToLongLivedDevice: Encodable {
        internal let deviceID: String
        internal let transport: String
        internal let subscriptionId: String?
        internal let language: String
        internal let region: String
        internal let platform: String
        internal let osVersion: String
        internal let sdkVersion: String
        internal let appVersion: String
        internal let deviceString: String
        internal let timeZoneOffset: Float
        internal let backgroundAppRefresh: Bool
    }

    internal enum Device {
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
