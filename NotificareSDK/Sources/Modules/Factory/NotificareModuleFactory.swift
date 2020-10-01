//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareModuleFactory {
    let applicationKey: String
    let applicationSecret: String

    func createPushManager() -> NotificarePushModule? {
        guard let cls = NSClassFromString(NotificareDefinitions.Modules.push) as? NotificarePushModule.Type else {
            Notificare.shared.logger.debug("Could not load NotificarePushManager.")
            return nil
        }

        return cls.init(applicationKey: applicationKey,
                        applicationSecret: applicationSecret)
    }

    func createLocationManager() -> NotificareLocationModule? {
        guard let cls = NSClassFromString(NotificareDefinitions.Modules.location) as? NotificareLocationModule.Type else {
            Notificare.shared.logger.debug("Could not load NotificareLocationManager.")
            return nil
        }

        return cls.init(applicationKey: applicationKey,
                        applicationSecret: applicationSecret)
    }
}
