//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareInternals {
    public enum Module: String, CaseIterable {
        // Embedded modules
        case events = "NotificareKit.NotificareEventsModuleImpl"
        case session = "NotificareKit.NotificareSessionModuleImpl"
        case device = "NotificareKit.NotificareDeviceModuleImpl"
        case crashReporter = "NotificareKit.NotificareCrashReporterModuleImpl"

        // Peer modules
        case push = "NotificarePushKit.NotificarePushImpl"
        case pushUI = "NotificarePushUIKit.NotificarePushUIImpl"
        case inbox = "NotificareInboxKit.NotificareInboxImpl"
        case loyalty = "NotificareLoyaltyKit.NotificareLoyaltyImpl"
        case assets = "NotificareAssetsKit.NotificareAssetsImpl"
        case scannables = "NotificareScannablesKit.NotificareScannablesImpl"
        case authentication = "NotificareAuthenticationKit.NotificareAuthenticationImpl"
        case geo = "NotificareGeoKit.NotificareGeoImpl"

        public var isAvailable: Bool {
            NSClassFromString(rawValue) != nil
        }

        internal var instance: NotificareModule.Type? {
            NSClassFromString(rawValue) as? NotificareModule.Type
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
