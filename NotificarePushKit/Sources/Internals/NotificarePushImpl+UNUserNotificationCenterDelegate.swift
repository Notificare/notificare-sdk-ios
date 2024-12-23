//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UserNotifications

extension NotificarePushImpl: NotificarePushUNUserNotificationCenterDelegate {
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        notificationCenterDelegate.userNotificationCenter(center, openSettingsFor: notification)
    }

    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task {
            await notificationCenterDelegate.userNotificationCenter(center, didReceive: response)

            await MainActor.run {
                completionHandler()
            }
        }
    }

    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await notificationCenterDelegate.userNotificationCenter(center, didReceive: response)
    }

    internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Task {
            let result = await notificationCenterDelegate.userNotificationCenter(center, willPresent: notification)

            await MainActor.run {
                completionHandler(result)
            }
        }
    }

    internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await notificationCenterDelegate.userNotificationCenter(center, willPresent: notification)
    }
}
