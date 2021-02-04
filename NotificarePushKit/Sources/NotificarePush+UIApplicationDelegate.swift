//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import UIKit

public extension NotificarePush {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        guard Notificare.shared.isConfigured else {
            NotificareLogger.warning("Notificare is not yet ready. Skipping...")
            return
        }

        Notificare.shared.deviceManager.registerAPNS(token: token.toHexString()) { result in
            switch result {
            case .success:
                NotificareLogger.debug("Registered the device with an APNS token.")
            case let .failure(error):
                NotificareLogger.debug("Failed to register the device with an APNS token: \(error)")
            }
        }
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificareLogger.error("Failed to register for remote notifications: \(error)")
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
                // TODO handle Wallet system notifications
                break
            case "re.notifica.notification.system.Products":
                // TODO handle Products system notifications
                break
            case "re.notifica.notification.system.Inbox":
                break
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

        guard Notificare.shared.isConfigured else {
            NotificareLogger.warning("Notificare has not been configured.")
            return
        }

        Notificare.shared.fetchNotification(id) { result in
            switch result {
            case let .success(notification):
                Notificare.shared.eventsManager.logNotificationReceived(notification)

                // Notify the inbox to add this item.
                NotificationCenter.default.post(name: NotificareDefinitions.InternalNotification.addInboxItem, object: nil, userInfo: userInfo)

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
