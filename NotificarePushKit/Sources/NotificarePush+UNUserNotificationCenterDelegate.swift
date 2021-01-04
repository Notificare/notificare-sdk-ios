//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UserNotifications

extension NotificarePush: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            // NOTE: log influenced only during launch options + receive

            guard let id = userInfo["id"] as? String else {
                Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
                completionHandler()
                return
            }

            guard let api = Notificare.shared.pushApi else {
                Notificare.shared.logger.warning("Notificare has not been configured.")
                completionHandler()
                return
            }

            api.getNotification(id) { result in
                switch result {
                case let .success(notification):
                    Notificare.shared.eventsManager.logNotificationOpen(notification)

                    if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                        if let clickedAction = notification.actions.first(where: { $0.label == response.actionIdentifier }) {
                            let data = NotificareNotification.ActionData(
                                identifier: response.actionIdentifier,
                                userText: (response as? UNTextInputNotificationResponse)?.userText
                            )

                            self.delegate?.notificare(self, didOpenAction: clickedAction, for: notification, with: data)
                        } else {
                            // TODO: handle scenario
                        }

                        // TODO: refresh badge
                        // [[NotificareInboxManager shared] refreshBadge:^(id  _Nullable response, NSError * _Nullable error) {
                        //     completion(.success(()))
                        // }];

                        completionHandler()
                    } else {
                        completionHandler()
                    }
                case .failure:
                    Notificare.shared.logger.error("Failed to fetch notification with id '\(id)'.")
                    completionHandler()
                }
            }
        } else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                var data = ["identifier": response.actionIdentifier]
                if let response = response as? UNTextInputNotificationResponse {
                    data["userText"] = response.userText
                }

                delegate?.notificare(self, didReceiveUnknownAction: response.actionIdentifier, for: userInfo, with: data)
            } else {
                delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            }

            completionHandler()
        }
    }

    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            guard let id = userInfo["id"] as? String else {
                Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
                return
            }

            guard let api = Notificare.shared.pushApi else {
                Notificare.shared.logger.warning("Notificare has not been configured.")
                return
            }

            api.getNotification(id) { result in
                switch result {
                case let .success(notification):
                    // TODO: log notification open?

                    // Check if we should force-set the presentation options.
                    if let presentation = userInfo["presentation"] as? Bool, presentation {
                        completionHandler([.alert, .badge, .sound])
                    } else {
                        completionHandler(self.presentationOptions)
                    }
                case .failure:
                    Notificare.shared.logger.error("Failed to fetch notification with id '\(id)'.")
                    completionHandler([])
                }
            }
        } else {
            // Unrecognizable notification
            delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            completionHandler([])
        }
    }

    public func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        guard let notification = notification else {
            delegate?.notificare(self, shouldOpenSettings: nil)
            return
        }

        let userInfo = notification.request.content.userInfo

        guard isNotificareNotification(userInfo) else {
            Notificare.shared.logger.debug("Cannot handle a notification from a provider other than Notificare.")
            return
        }

        guard let id = userInfo["id"] as? String else {
            Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard let api = Notificare.shared.pushApi else {
            Notificare.shared.logger.warning("Notificare has not been configured.")
            return
        }

        api.getNotification(id) { result in
            switch result {
            case let .success(notification):
                self.delegate?.notificare(self, shouldOpenSettings: notification)
            case .failure:
                Notificare.shared.logger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }
}
