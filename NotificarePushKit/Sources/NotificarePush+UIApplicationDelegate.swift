//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public extension NotificarePush {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        guard Notificare.shared.isReady else {
            Notificare.shared.logger.warning("Notificare is not yet ready. Skipping...")
            return
        }

        Notificare.shared.deviceManager.registerAPNS(token: token.toHexString()) { result in
            switch result {
            case .success:
                Notificare.shared.logger.debug("Registered the device with an APNS token.")
            case let .failure(error):
                Notificare.shared.logger.debug("Failed to register the device with an APNS token: \(error)")
            }
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Notificare.shared.logger.error("Failed to register for remote notifications: \(error)")
        delegate?.notificare(self, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if isNotificareNotification(userInfo) {
            let isSystemNotification = userInfo["system"] as? Bool ?? false

            if isSystemNotification {
                Notificare.shared.logger.info("Received a system notification from APNS.")
                handleSystemNotification(userInfo) { _ in
                    completionHandler(.newData)
                }
            } else {
                Notificare.shared.logger.info("Received a notification from APNS.")
                handleNotification(userInfo) { _ in
                    // TODO: add to inbox
                    completionHandler(.newData)
                }
            }
        } else {
            Notificare.shared.logger.info("Received an unknown notification from APNS.")
            delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            completionHandler(.newData)
        }
    }
}
