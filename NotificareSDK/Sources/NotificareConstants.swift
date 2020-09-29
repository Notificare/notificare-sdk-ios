//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareConstants {
    static let sdkVersion = "3.0.0"
    static let databaseVersion = "3.0.0"

    private init() {}

    struct UserDefaults {
        static let currentDatabaseVersion = "re.notifica.local.currentDatabaseVersion"
        static let newRegistration = "re.notifica.local.newRegistration"
        static let preferredLanguage = "re.notifica.local.preferredLanguage"
        static let preferredRegion = "re.notifica.local.preferredRegion"
        static let registeredDevice = "re.notifica.local.registeredDevice"

        private init() {}
    }

    struct BackgroundTasks {
        static let processEvents = "re.notifica.tasks.process.events"
    }
}
