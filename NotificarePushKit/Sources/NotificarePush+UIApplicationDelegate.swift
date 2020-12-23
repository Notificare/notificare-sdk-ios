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

    func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}
}
