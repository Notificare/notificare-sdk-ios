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

        Notificare.shared.deviceInternal().registerAPNS(token: token.toHexString()) { result in
            switch result {
            case .success:
                NotificareLogger.debug("Registered the device with an APNS token.")
            case let .failure(error):
                NotificareLogger.debug("Failed to register the device with an APNS token.", error: error)
            }
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificareLogger.error("Failed to register for remote notifications.", error: error)
        delegate?.notificare(self, didFailToRegisterForRemoteNotificationsWithError: error)
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
            NotificareLogger.info("Received an unknown notification from APNS.")
            delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            completionHandler(.newData)
        }
    }

    private func handleSystemNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        if let type = userInfo["systemType"] as? String, type.hasPrefix("re.notifica.") {
            NotificareLogger.info("Processing system notification: \(type)")

            switch type {
            case "re.notifica.notification.system.Application":
                NotificareLogger.debug("Processing application system notification.")
                Notificare.shared.fetchApplication { result in
                    switch result {
                    case .success:
                        self.reloadActionCategories()
                        completion(.success(()))

                    case .failure:
                        completion(.success(()))
                    }
                }

            case "re.notifica.notification.system.Wallet":
                // TODO: reserved for future implementation of in-app wallet
                NotificareLogger.debug("Processing wallet system notification.")
                completion(.success(()))

            case "re.notifica.notification.system.Products":
                NotificareLogger.debug("Processing products system notification.")
                // TODO: handle Products system notifications
                completion(.success(()))

            case "re.notifica.notification.system.Inbox":
                NotificareLogger.debug("Processing inbox system notification.")
                InboxIntegration.reloadInbox()

                completion(.success(()))

            default:
                NotificareLogger.warning("Unhandled system notification: \(type)")
            }
        } else {
            NotificareLogger.info("Processing custom system notification.")

            let notification = NotificareSystemNotification(userInfo: userInfo)
            delegate?.notificare(self, didReceiveSystemNotification: notification)

            completion(.success(()))
        }
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        guard let id = userInfo["id"] as? String else {
            NotificareLogger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard let notificationId = userInfo["notificationId"] as? String else {
            NotificareLogger.warning("Missing 'notificationId' property in notification payload.")
            return
        }

        guard Notificare.shared.isConfigured else {
            NotificareLogger.warning("Notificare has not been configured.")
            return
        }

        Notificare.shared.events().logNotificationReceived(notificationId) { _ in }

        Notificare.shared.fetchNotification(id) { result in
            switch result {
            case let .success(notification):
                // Put the notification in the inbox, if appropriate.
                InboxIntegration.addItemToInbox(userInfo: userInfo, notification: notification)

                // Notify the delegate.
                self.delegate?.notificare(self, didReceiveNotification: notification)

                completion(.success(()))
            case let .failure(error):
                NotificareLogger.error("Failed to fetch notification.", error: error)

                // Put the notification in the inbox, if appropriate.
                if let notification = NotificareNotification(apnsDictionary: userInfo) {
                    // Put the notification in the inbox, if appropriate.
                    InboxIntegration.addItemToInbox(userInfo: userInfo, notification: notification)

                    // Notify the delegate.
                    self.delegate?.notificare(self, didReceiveNotification: notification)

                    completion(.success(()))
                } else {
                    NotificareLogger.debug("Unable to create a partial notification from the APNS payload.")
                    completion(.failure(error))
                }
            }
        }
    }
}
