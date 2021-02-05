//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificarePushKit
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        NotificarePush.shared.fetchAttachment(for: request.content.userInfo) { result in
            switch result {
            case let .success(attachment):
                if let bestAttemptContent = self.bestAttemptContent {
                    bestAttemptContent.attachments = [attachment]
                    contentHandler(bestAttemptContent)
                }

            case .failure:
                if let bestAttemptContent = self.bestAttemptContent {
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
