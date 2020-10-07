//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareDefinitions {
    static let sdkVersion = "3.0.0"
    static let databaseVersion = "3.0.0"

    struct Modules {
        static let push = "NotificarePush.NotificarePushManagerImpl"
        static let location = "NotificareLocation.NotificareLocationManagerImpl"
    }

    struct UserDefaults {
        static let currentDatabaseVersion = "re.notifica.local.currentDatabaseVersion"
        static let sessionDate = "re.notifica.local.sessionDate"
        static let newRegistration = "re.notifica.local.newRegistration"
        static let preferredLanguage = "re.notifica.local.preferredLanguage"
        static let preferredRegion = "re.notifica.local.preferredRegion"
        static let registeredDevice = "re.notifica.local.registeredDevice"
        static let crashReport = "re.notifica.local.crashReport"
    }

    struct Tasks {
        static let processEvents = "re.notifica.tasks.process.events"
    }

    struct Events {
        static let applicationInstall = "re.notifica.event.application.Install"
        static let applicationRegistration = "re.notifica.event.application.Registration"
        static let applicationUpgrade = "re.notifica.event.application.Upgrade"
        static let applicationOpen = "re.notifica.event.application.Open"
        static let applicationClose = "re.notifica.event.application.Close"
        static let applicationException = "re.notifica.event.application.Exception"
    }
}
