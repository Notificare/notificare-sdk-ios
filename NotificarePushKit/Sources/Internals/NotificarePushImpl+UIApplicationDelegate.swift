//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

extension NotificarePushImpl: NotificareAppDelegateInterceptor {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        guard Notificare.shared.isConfigured else {
            NotificareLogger.warning("Notificare is not yet ready. Skipping...")
            return
        }

        Task {
            do {
                try await Notificare.shared.deviceInternal().registerAPNS(token: token.toHexString())
                NotificareLogger.debug("Registered the device with an APNS token.")
            } catch {
                NotificareLogger.debug("Failed to register the device with an APNS token.", error: error)
            }

            try? await self.updateNotificationSettings()
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DispatchQueue.main.async {
            NotificareLogger.error("Failed to register for remote notifications.", error: error)
            self.delegate?.notificare(self, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if isNotificareNotification(userInfo) {
            let isSystemNotification = userInfo["system"] as? Bool ?? false

            if isSystemNotification {
                NotificareLogger.info("Received a system notification from APNS.")
                handleSystemNotification(userInfo) { _ in
                    completionHandler(.newData)
                }
            } else {
                NotificareLogger.info("Received a notification from APNS.")
                handleNotification(userInfo) { _ in
                    completionHandler(.newData)
                }
            }
        } else {
            DispatchQueue.main.async {
                NotificareLogger.info("Received an unknown notification from APNS.")
                self.delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            }

            completionHandler(.newData)
        }
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        if isNotificareNotification(userInfo) {
            let isSystemNotification = userInfo["system"] as? Bool ?? false

            if isSystemNotification {
                NotificareLogger.info("Received a system notification from APNS.")
                
                do {
                    try await handleSystemNotification(userInfo)
                    return .newData
                } catch {}
            } else {
                NotificareLogger.info("Received a notification from APNS.")
                
                do {
                    try await handleNotification(userInfo)
                    return .newData
                } catch {}
            }
        } else {
            DispatchQueue.main.async {
                NotificareLogger.info("Received an unknown notification from APNS.")
                self.delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            }

            return .newData
        }

        return .noData
    }

    private func handleSystemNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await handleSystemNotification(userInfo)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func handleSystemNotification(_ userInfo: [AnyHashable: Any]) async throws {
        if let type = userInfo["systemType"] as? String, type.hasPrefix("re.notifica.") {
            NotificareLogger.info("Processing system notification: \(type)")

            switch type {
            case "re.notifica.notification.system.Application":
                NotificareLogger.debug("Processing application system notification.")

                do {
                    _ = try await Notificare.shared.fetchApplication()

                    await self.reloadActionCategories()
                    return
                } catch {
                    return
                }

            case "re.notifica.notification.system.Wallet":
                // TODO: reserved for future implementation of in-app wallet
                NotificareLogger.debug("Processing wallet system notification.")
                return

            case "re.notifica.notification.system.Products":
                NotificareLogger.debug("Processing products system notification.")
                // TODO: handle Products system notifications
                return

            case "re.notifica.notification.system.Inbox":
                NotificareLogger.debug("Processing inbox system notification.")
                InboxIntegration.reloadInbox()

                return

            default:
                NotificareLogger.warning("Unhandled system notification: \(type)")
            }
        } else {
            NotificareLogger.info("Processing custom system notification.")

            let notification = NotificareSystemNotification(userInfo: userInfo)

            DispatchQueue.main.async {
                self.delegate?.notificare(self, didReceiveSystemNotification: notification)
            }

            return
        }
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await handleNotification(userInfo)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any]) async throws {
        guard let id = userInfo["id"] as? String else {
            NotificareLogger.warning("Missing 'id' property in notification payload.")
            throw NotificareError.invalidArgument(message: "Missing 'id' property in notification payload.")
        }

        guard let notificationId = userInfo["notificationId"] as? String else {
            NotificareLogger.warning("Missing 'notificationId' property in notification payload.")
            throw NotificareError.invalidArgument(message: "Missing 'notificationId' property in notification payload.")
        }

        guard Notificare.shared.isConfigured else {
            NotificareLogger.warning("Notificare has not been configured.")
            throw NotificareError.notConfigured
        }

        let deliveryMechanism: NotificareNotificationDeliveryMechanism = containsApsAlert(userInfo) ? .standard : .silent

        try await Notificare.shared.events().logNotificationReceived(notificationId)

        do {
            let notification = try await Notificare.shared.fetchNotification(id)

            // Put the notification in the inbox, if appropriate.
            InboxIntegration.addItemToInbox(userInfo: userInfo, notification: notification)

            DispatchQueue.main.async {
                // Notify the delegate.
                self.delegate?.notificare(self, didReceiveNotification: notification, deliveryMechanism: deliveryMechanism)

                // Continue notifying the deprecated delegate method to preserve backwards compatibility.
                self.delegate?.notificare(self, didReceiveNotification: notification)
            }

        } catch {
            NotificareLogger.error("Failed to fetch notification.", error: error)

            // Put the notification in the inbox, if appropriate.
            if let notification = NotificareNotification(apnsDictionary: userInfo) {
                // Put the notification in the inbox, if appropriate.
                InboxIntegration.addItemToInbox(userInfo: userInfo, notification: notification)

                DispatchQueue.main.async {
                    // Notify the delegate.
                    self.delegate?.notificare(self, didReceiveNotification: notification, deliveryMechanism: deliveryMechanism)

                    // Continue notifying the deprecated delegate method to preserve backwards compatibility.
                    self.delegate?.notificare(self, didReceiveNotification: notification)
                }

            } else {
                NotificareLogger.debug("Unable to create a partial notification from the APNS payload.")
                throw error
            }
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
