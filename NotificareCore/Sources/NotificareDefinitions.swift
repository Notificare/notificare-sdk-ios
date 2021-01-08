//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareDefinitions {
    public enum Modules: String, CaseIterable {
        case push = "NotificarePushKit.NotificarePush"
        case pushUI = "NotificarePushUIKit.NotificarePushUI"
    }

    public enum UserDefaults {
        public static let currentDatabaseVersion = "re.notifica.local.currentDatabaseVersion"
        public static let preferredLanguage = "re.notifica.local.preferredLanguage"
        public static let preferredRegion = "re.notifica.local.preferredRegion"
        public static let registeredDevice = "re.notifica.local.registeredDevice"
        public static let crashReport = "re.notifica.local.crashReport"
    }
}
