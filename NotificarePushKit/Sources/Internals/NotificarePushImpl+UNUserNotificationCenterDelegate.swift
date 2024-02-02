//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UserNotifications

extension NotificarePushImpl: NotificarePushUNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        notificationCenterDelegate.userNotificationCenter(center, openSettingsFor: notification)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Task {
            await notificationCenterDelegate.userNotificationCenter(center, didReceive: response)
            completionHandler()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await notificationCenterDelegate.userNotificationCenter(center, didReceive: response)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Task {
            let result = await notificationCenterDelegate.userNotificationCenter(center, willPresent: notification)
            completionHandler(result)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await notificationCenterDelegate.userNotificationCenter(center, willPresent: notification)
    }
}
