//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareInternals {
    public enum Module: String, CaseIterable {
        // Embedded modules
        case device = "NotificareKit.NotificareDeviceModuleImpl"
        case session = "NotificareKit.NotificareSessionModuleImpl"
        case events = "NotificareKit.NotificareEventsModuleImpl"
        case crashReporter = "NotificareKit.NotificareCrashReporterModuleImpl"

        // Peer modules
        case push = "NotificarePushKit.NotificarePushImpl"
        case pushUI = "NotificarePushUIKit.NotificarePushUIImpl"
        case inbox = "NotificareInboxKit.NotificareInboxImpl"
        case loyalty = "NotificareLoyaltyKit.NotificareLoyaltyImpl"
        case assets = "NotificareAssetsKit.NotificareAssetsImpl"
        case scannables = "NotificareScannablesKit.NotificareScannablesImpl"
        case geo = "NotificareGeoKit.NotificareGeoImpl"
        case inAppMessaging = "NotificareInAppMessagingKit.NotificareInAppMessagingImpl"
        case userInbox = "NotificareUserInboxKit.NotificareUserInboxImpl"

        public var isAvailable: Bool {
            NSClassFromString(rawValue) != nil
        }

        public var klass: (any NotificareModule.Type)? {
            NSClassFromString(rawValue) as? any NotificareModule.Type
        }

        internal var isPeer: Bool {
            switch self {
            case .device, .events, .session, .crashReporter:
                return false
            default:
                return true
            }
        }
    }
}
