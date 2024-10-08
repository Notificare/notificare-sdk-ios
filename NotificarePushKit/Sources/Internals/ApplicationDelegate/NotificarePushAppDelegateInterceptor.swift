//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

internal class NotificarePushAppDelegateInterceptor: NSObject, NotificareAppDelegateInterceptor {
    internal func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Notificare.shared.pushImplementation().pushTokenRequester.signalTokenReceived(deviceToken)
    }

    internal func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for remote notifications.", error: error)

        Notificare.shared.pushImplementation().pushTokenRequester.signalTokenRequestError(error)

        DispatchQueue.main.async {
            Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    internal func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard Notificare.shared.push().isNotificareNotification(userInfo) else {
            logger.info("Received an unknown notification from APNS.")

            DispatchQueue.main.async {
                Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didReceiveUnknownNotification: userInfo)
            }

            completionHandler(.newData)
            return
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application unavailable. Ensure Notificare is configured during the application launch.")
            completionHandler(.newData)
            return
        }

        guard application.id == userInfo["x-application"] as? String else {
            logger.warning("Incoming notification originated from another application.")
            completionHandler(.newData)
            return
        }

        Task {
            let isSystemNotification = userInfo["system"] as? Bool ?? false

            if isSystemNotification {
                logger.info("Received a system notification from APNS.")
                await handleSystemNotification(userInfo)
            } else {
                logger.info("Received a notification from APNS.")
                await handleNotification(userInfo)
            }

            completionHandler(.newData)
        }
    }

    private func handleSystemNotification(_ userInfo: [AnyHashable: Any]) async {
        if let type = userInfo["systemType"] as? String, type.hasPrefix("re.notifica.") {
            logger.info("Processing system notification: \(type)")

            switch type {
            case "re.notifica.notification.system.Application":
                logger.debug("Processing application system notification.")

                do {
                    _ = try await Notificare.shared.fetchApplication()
                    await Notificare.shared.pushImplementation().reloadActionCategories()
                } catch {
                    logger.warning("Failed to refresh the application info.", error: error)
                }

                return

            case "re.notifica.notification.system.Inbox":
                logger.debug("Processing inbox system notification.")
                InboxIntegration.reloadInbox()

                return

            default:
                logger.warning("Unhandled system notification: \(type)")
            }

            return
        }

        logger.info("Processing custom system notification.")

        let notification = NotificareSystemNotification(userInfo: userInfo)

        DispatchQueue.main.async {
            Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didReceiveSystemNotification: notification)
        }
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any]) async {
        guard let id = userInfo["id"] as? String else {
            logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard let notificationId = userInfo["notificationId"] as? String else {
            logger.warning("Missing 'notificationId' property in notification payload.")
            return
        }

        guard Notificare.shared.isConfigured else {
            logger.warning("Notificare has not been configured.")
            return
        }

        try? await Notificare.shared.events().logNotificationReceived(notificationId)

        let notification: NotificareNotification
        let deliveryMechanism: NotificareNotificationDeliveryMechanism = containsApsAlert(userInfo) ? .standard : .silent

        do {
            notification = try await Notificare.shared.fetchNotification(id)
        } catch {
            logger.error("Failed to fetch notification.", error: error)

            if let partialNotification = NotificareNotification(apnsDictionary: userInfo) {
                notification = partialNotification
            } else {
                logger.debug("Unable to create a partial notification from the APNS payload.")
                return
            }
        }

        // Put the notification in the inbox, if appropriate.
        InboxIntegration.addItemToInbox(userInfo: userInfo, notification: notification)

        DispatchQueue.main.async {
            // Notify the delegate.
            Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didReceiveNotification: notification, deliveryMechanism: deliveryMechanism)
        }
    }

    private func containsApsAlert(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            return false
        }

        guard aps["alert"] is [String: Any] else {
            return false
        }

        return true
    }
}
