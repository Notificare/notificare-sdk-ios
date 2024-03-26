//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificationCenter

internal class NotificareNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    internal func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        guard response.actionIdentifier != UNNotificationDismissActionIdentifier else {
            return
        }

        guard Notificare.shared.push().isNotificareNotification(userInfo) else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
                let responseText = (response as? UNTextInputNotificationResponse)?.userText

                DispatchQueue.main.async {
                    Notificare.shared.push().delegate?.notificare(
                        Notificare.shared.push(),
                        didOpenUnknownAction: response.actionIdentifier,
                        for: userInfo,
                        responseText: responseText
                    )
                }
            } else {
                DispatchQueue.main.async {
                    Notificare.shared.push().delegate?.notificare(
                        Notificare.shared.push(),
                        didOpenUnknownNotification: userInfo
                    )
                }
            }

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

        let notification: NotificareNotification

        do {
            notification = try await Notificare.shared.fetchNotification(id)
        } catch {
            NotificareLogger.error("Failed to fetch notification with id '\(id)'.", error: error)
            return
        }

        do {
            try await Notificare.shared.events().logNotificationOpen(id)
        } catch {
            NotificareLogger.error("Failed to log the notification as open.", error: error)
            return
        }

        if response.actionIdentifier != UNNotificationDefaultActionIdentifier {
            if let clickedAction = notification.actions.first(where: { $0.label == response.actionIdentifier }) {
                let responseText = (response as? UNTextInputNotificationResponse)?.userText

                if clickedAction.type == NotificareNotification.Action.ActionType.callback.rawValue, !clickedAction.camera, !clickedAction.keyboard || responseText != nil {
                    NotificareLogger.debug("Handling a notification action without UI.")
                    handleQuickResponse(userInfo: userInfo, notification: notification, action: clickedAction, responseText: responseText)
                    return
                }

                do {
                    try await Notificare.shared.events().logNotificationInfluenced(id)
                } catch {
                    NotificareLogger.error("Failed to log the notification influenced open.", error: error)
                    return
                }

                InboxIntegration.markItemAsRead(userInfo: userInfo)

                DispatchQueue.main.async {
                    Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didOpenAction: clickedAction, for: notification)
                }

                return
            }

            // Notify the inbox to update the badge.
            InboxIntegration.refreshBadge()
        } else {
            do {
                try await Notificare.shared.events().logNotificationInfluenced(id)
            } catch {
                NotificareLogger.error("Failed to log the notification influenced open.", error: error)
                return
            }

            InboxIntegration.markItemAsRead(userInfo: userInfo)

            DispatchQueue.main.async {
                Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), didOpenNotification: notification)
            }
        }
    }

    internal func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        guard Notificare.shared.push().isNotificareNotification(userInfo) else {
            // Unrecognizable notification
            return Notificare.shared.push().presentationOptions
        }

        // Check if we should force-set the presentation options.
        if let presentation = userInfo["presentation"] as? Bool, presentation {
            if #available(iOS 14.0, *) {
                return [.banner, .badge, .sound]
            } else {
                return [.alert, .badge, .sound]
            }
        }

        return Notificare.shared.push().presentationOptions
    }

    internal func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        guard let notification = notification else {
            DispatchQueue.main.async {
                Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), shouldOpenSettings: nil)
            }

            return
        }

        let userInfo = notification.request.content.userInfo

        guard Notificare.shared.pushImplementation().isNotificareNotification(userInfo) else {
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
                    Notificare.shared.push().delegate?.notificare(Notificare.shared.push(), shouldOpenSettings: notification)
                }
            case .failure:
                NotificareLogger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }

    private func handleQuickResponse(userInfo: [AnyHashable: Any], notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?) {
        Task {
            try? await sendQuickResponse(notification: notification, action: action, responseText: responseText)

            // Remove the notification from the notification center.
            Notificare.shared.removeNotificationFromNotificationCenter(notification)

            // Notify the inbox to mark the item as read.
            InboxIntegration.markItemAsRead(userInfo: userInfo)
        }
    }

    private func sendQuickResponse(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?) async throws {
        guard let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil else {
            try await sendQuickResponseAction(notification: notification, action: action, responseText: responseText)
            return
        }

        var params = [
            "notificationID": notification.id,
            "label": action.label,
        ]

        if let responseText = responseText {
            params["message"] = responseText
        }

        do {
            try await Notificare.shared.callNotificationReplyWebhook(url: url, data: params)
        } catch {
            NotificareLogger.debug("Failed to call the notification reply webhook.", error: error)
        }

        try await sendQuickResponseAction(notification: notification, action: action, responseText: responseText)
    }

    private func sendQuickResponseAction(notification: NotificareNotification, action: NotificareNotification.Action, responseText: String?) async throws {
        do {
            try await Notificare.shared.createNotificationReply(notification: notification, action: action, message: responseText, media: nil, mimeType: nil)
        } catch {
            NotificareLogger.debug("Failed to create a notification reply.", error: error)
            throw error
        }
    }
}
