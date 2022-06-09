//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UserNotifications

extension NotificarePushImpl: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        guard response.actionIdentifier != UNNotificationDismissActionIdentifier else {
            completionHandler()
            return
        }

        if isNotificareNotification(userInfo) {
            guard let id = userInfo["id"] as? String else {
                NotificareLogger.warning("Missing 'id' property in notification payload.")
                return completionHandler()
            }

            guard Notificare.shared.isConfigured else {
                NotificareLogger.warning("Notificare has not been configured.")
                return completionHandler()
            }

            Notificare.shared.fetchNotification(id) { result in
                switch result {
                case let .success(notification):
                    Notificare.shared.events().logNotificationOpen(id) { result in
                        switch result {
                        case .success:
                            if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
                                if let clickedAction = notification.actions.first(where: { $0.label == response.actionIdentifier }) {
                                    let responseText = (response as? UNTextInputNotificationResponse)?.userText

                                    if clickedAction.type == NotificareNotification.Action.ActionType.callback.rawValue, !clickedAction.camera, !clickedAction.keyboard || responseText != nil {
                                        NotificareLogger.debug("Handling a notification action without UI.")
                                        self.handleQuickResponse(userInfo: userInfo, notification: notification, action: clickedAction, responseText: responseText)
                                        return completionHandler()
                                    }

                                    Notificare.shared.events().logNotificationInfluenced(id) { result in
                                        switch result {
                                        case .success:
                                            InboxIntegration.markItemAsRead(userInfo: userInfo)

                                            DispatchQueue.main.async {
                                                self.delegate?.notificare(self, didOpenAction: clickedAction, for: notification)
                                            }
                                        case let .failure(error):
                                            NotificareLogger.error("Failed to log the notification influenced open.", error: error)
                                        }

                                        completionHandler()
                                    }

                                    return
                                }

                                // Notify the inbox to update the badge.
                                InboxIntegration.refreshBadge()

                                completionHandler()
                            } else {
                                Notificare.shared.events().logNotificationInfluenced(id) { result in
                                    switch result {
                                    case .success:
                                        InboxIntegration.markItemAsRead(userInfo: userInfo)

                                        DispatchQueue.main.async {
                                            self.delegate?.notificare(self, didOpenNotification: notification)
                                        }
                                    case let .failure(error):
                                        NotificareLogger.error("Failed to log the notification influenced open.", error: error)
                                    }

                                    completionHandler()
                                }
                            }

                        case let .failure(error):
                            NotificareLogger.error("Failed to log the notification as open.", error: error)
                            completionHandler()
                        }
                    }

                case let .failure(error):
                    NotificareLogger.error("Failed to fetch notification with id '\(id)'.", error: error)
                    completionHandler()
                }
            }
        } else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
                var responseText: String?
                if let response = response as? UNTextInputNotificationResponse {
                    responseText = response.userText
                }

                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didOpenUnknownAction: response.actionIdentifier, for: userInfo, responseText: responseText)
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, didOpenUnknownNotification: userInfo)
                }
            }

            completionHandler()
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            // Check if we should force-set the presentation options.
            if let presentation = userInfo["presentation"] as? Bool, presentation {
                if #available(iOS 14.0, *) {
                    completionHandler([.banner, .badge, .sound])
                } else {
                    completionHandler([.alert, .badge, .sound])
                }
            } else {
                completionHandler(presentationOptions)
            }
        } else {
            // Unrecognizable notification
            completionHandler(presentationOptions)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        guard let notification = notification else {
            DispatchQueue.main.async {
                self.delegate?.notificare(self, shouldOpenSettings: nil)
            }

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
                DispatchQueue.main.async {
                    self.delegate?.notificare(self, shouldOpenSettings: notification)
                }
            case .failure:
                NotificareLogger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }

    private func handleQuickResponse(userInfo: [AnyHashable: Any], notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?) {
        sendQuickResponse(notification: notification, action: action, responseText: responseText) { _ in
            // Remove the notification from the notification center.
            Notificare.shared.removeNotificationFromNotificationCenter(notification)

            // Notify the inbox to mark the item as read.
            InboxIntegration.markItemAsRead(userInfo: userInfo)
        }
    }

    private func sendQuickResponse(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
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
                NotificareLogger.debug("Failed to call the notification reply webhook.", error: error)
            }

            self.sendQuickResponseAction(notification: notification, action: action, responseText: responseText, completion)
        }
    }

    private func sendQuickResponseAction(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?, _ completion: @escaping NotificareCallback<Void>) {
        Notificare.shared.createNotificationReply(notification: notification, action: action, message: responseText, media: nil, mimeType: nil) { result in
            if case let .failure(error) = result {
                NotificareLogger.debug("Failed to create a notification reply.", error: error)
            }

            completion(result)
        }
    }
}
