//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UserNotifications

extension NotificarePush: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            guard let id = userInfo["id"] as? String else {
                NotificareLogger.warning("Missing 'id' property in notification payload.")
                completionHandler()
                return
            }

            guard Notificare.shared.isConfigured else {
                NotificareLogger.warning("Notificare has not been configured.")
                completionHandler()
                return
            }

            Notificare.shared.fetchNotification(id) { result in
                switch result {
                case let .success(notification):
                    Notificare.shared.eventsManager.logNotificationOpen(notification) { result in
                        switch result {
                        case .success:
                            if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                                if let clickedAction = notification.actions.first(where: { $0.label == response.actionIdentifier }) {
                                    let responseText = (response as? UNTextInputNotificationResponse)?.userText

                                    if clickedAction.type == NotificareNotification.Action.ActionType.callback.rawValue, !clickedAction.camera, !clickedAction.keyboard || responseText != nil {
                                        NotificareLogger.debug("Handling a notification action without UI.")
                                        self.handleQuickResponse(userInfo: userInfo, notification: notification, action: clickedAction, responseText: responseText)
                                    } else {
                                        self.delegate?.notificare(self, didOpenAction: clickedAction, for: notification)
                                    }
                                }

                                // Notify the inbox to update the badge.
                                InboxIntegration.refreshBadge()

                                completionHandler()
                            } else {
                                self.delegate?.notificare(self, didOpenNotification: notification)

                                // Notify the inbox to mark this as read.
                                InboxIntegration.markItemAsRead(userInfo: userInfo)

                                completionHandler()
                            }

                        case let .failure(error):
                            NotificareLogger.error("Failed to log the notification as open.")
                            NotificareLogger.debug("\(error)")
                            completionHandler()
                        }
                    }

                case let .failure(error):
                    NotificareLogger.error("Failed to fetch notification with id '\(id)'.")
                    NotificareLogger.debug("\(error)")
                    completionHandler()
                }
            }
        } else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                var responseText: String?
                if let response = response as? UNTextInputNotificationResponse {
                    responseText = response.userText
                }

                delegate?.notificare(self, didReceiveUnknownAction: response.actionIdentifier, for: userInfo, responseText: responseText)
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
                    // TODO: log notification open?

                    // Check if we should force-set the presentation options.
                    if let presentation = userInfo["presentation"] as? Bool, presentation {
                        completionHandler([.alert, .badge, .sound])
                    } else {
                        completionHandler(self.presentationOptions)
                    }
                case .failure:
                    NotificareLogger.error("Failed to fetch notification with id '\(id)'.")
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
            NotificareLogger.debug("Cannot handle a notification from a provider other than Notificare.")
            return
        }

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
                self.delegate?.notificare(self, shouldOpenSettings: notification)
            case .failure:
                NotificareLogger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }

    private func handleQuickResponse(userInfo: [AnyHashable: Any], notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?) {
        // Log the notification open event.
        Notificare.shared.eventsManager.logNotificationOpen(notification.id)

        sendQuickResponse(notification: notification, action: action, responseText: responseText) { _ in
            // Remove the notification from the notification center.
            Notificare.shared.removeNotificationFromNotificationCenter(notification)

            // Notify the inbox to mark the item as read.
            InboxIntegration.markItemAsRead(userInfo: userInfo)
        }
    }

    private func sendQuickResponse(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            // NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            sendQuickResponseAction(notification: notification, action: action, responseText: responseText, completion)

            return
        }

        var params = [
            "notificationID": notification.id,
            "label": action.label,
        ]

        if let responseText = responseText {
            params["message"] = responseText
        }

        Notificare.shared.callNotificationReplyWebhook(url: url, data: params) { result in
            if case let .failure(error) = result {
                NotificareLogger.debug("Failed to call the notification reply webhook.\n\(error)")
            }

            self.sendQuickResponseAction(notification: notification, action: action, responseText: responseText, completion)
        }
    }

    private func sendQuickResponseAction(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?, _ completion: @escaping NotificareCallback<Void>) {
        Notificare.shared.createNotificationReply(notification: notification, action: action, message: responseText, media: nil, mimeType: nil) { result in
            if case let .failure(error) = result {
                NotificareLogger.debug("Failed to create a notification reply.\n\(error)")
            }

            completion(result)
        }
    }
}
