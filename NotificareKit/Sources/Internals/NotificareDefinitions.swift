//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDefinitions {
    static let sdkVersion = "3.0.0"
    static let databaseVersion = "3.0.0"

    enum Modules: String, CaseIterable {
        case push = "NotificarePushKit.NotificarePush"
        // static let location = "NotificareLocation.NotificareLocationManagerImpl"
    }

    enum UserDefaults {
        static let currentDatabaseVersion = "re.notifica.local.currentDatabaseVersion"
        static let preferredLanguage = "re.notifica.local.preferredLanguage"
        static let preferredRegion = "re.notifica.local.preferredRegion"
        static let registeredDevice = "re.notifica.local.registeredDevice"
        static let crashReport = "re.notifica.local.crashReport"
    }

    enum Tasks {
        static let processEvents = "re.notifica.tasks.process.events"
        static let applicationClose = "re.notifica.tasks.applicationClose"
    }

    enum Events {
        static let applicationInstall = "re.notifica.event.application.Install"
        static let applicationRegistration = "re.notifica.event.application.Registration"
        static let applicationUpgrade = "re.notifica.event.application.Upgrade"
        static let applicationOpen = "re.notifica.event.application.Open"
        static let applicationClose = "re.notifica.event.application.Close"
        static let applicationException = "re.notifica.event.application.Exception"
    }
}
