//
//  NotificareModuleFactory.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareModuleFactory {

    func createPushManager() -> NotificarePushManager? {
        guard let cls = NSClassFromString("NotificarePush.NotificarePushManagerImpl") as? NotificarePushManager.Type else {
            Notificare.shared.logger.debug("Could not load NotificarePushManager.")
            return nil
        }

        return cls.init(applicationKey: Notificare.shared.applicationKey,
                applicationSecret: Notificare.shared.applicationSecret)
    }

    func createLocationManager() -> NotificareLocationManager? {
        guard let cls = NSClassFromString("NotificareLocation.NotificareLocationManagerImpl") as? NotificareLocationManager.Type else {
            Notificare.shared.logger.debug("Could not load NotificareLocationManager.")
            return nil
        }

        return cls.init(applicationKey: Notificare.shared.applicationKey,
                applicationSecret: Notificare.shared.applicationSecret)
    }
}
