//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareNotification {
    init?(apnsDictionary: [AnyHashable: Any]) {
        let aps = apnsDictionary["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any] ?? apnsDictionary["alert"] as? [String: Any]

        guard let type = apnsDictionary["notificationType"] as? String,
              let notificationId = apnsDictionary["notificationId"] as? String,
              let message = alert?["body"] as? String
        else {
            return nil
        }

        let attachments: [NotificareNotification.Attachment]
        if let attachment = apnsDictionary["attachment"] as? [String: Any],
           let mimeType = attachment["mimeType"] as? String,
           let uri = attachment["uri"] as? String
        {
            attachments = [NotificareNotification.Attachment(mimeType: mimeType, uri: uri)]
        } else {
            attachments = []
        }

        let ignoreKeys = ["aps", "alert", "inboxItemId", "inboxItemVisible", "inboxItemExpires", "system", "systemType", "attachment", "notificationId", "notificationType", "id", "x-sender"]
        let extra = apnsDictionary
            .filter { $0.key is String }
            .mapKeys { $0 as! String }
            .filter { !ignoreKeys.contains($0.key) }

        self.init(
            partial: true,
            id: notificationId,
            type: type,
            time: Date(),
            title: alert?["title"] as? String,
            subtitle: alert?["subtitle"] as? String,
            message: message,
            content: [],
            actions: [],
            attachments: attachments,
            extra: extra,
            targetContentIdentifier: nil
        )
    }
}
