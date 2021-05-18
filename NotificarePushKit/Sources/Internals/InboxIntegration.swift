//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal class InboxIntegration {
    private static let addInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.AddInboxItem")
    private static let readInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReadInboxItem")
    private static let refreshBadgeNotification = NSNotification.Name(rawValue: "NotificareInboxKit.RefreshBadge")
    private static let reloadInboxNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReloadInbox")

    private init() {}

    static func reloadInbox() {
        NotificationCenter.default.post(
            name: reloadInboxNotification,
            object: nil,
            userInfo: nil
        )
    }

    static func refreshBadge() {
        NotificationCenter.default.post(
            name: refreshBadgeNotification,
            object: nil,
            userInfo: nil
        )
    }

    static func addItemToInbox(userInfo: [AnyHashable: Any], notification: NotificareNotification) {
        guard let inboxItemId = userInfo["inboxItemId"] as? String else {
            NotificareLogger.debug("Received a notification payload without an inbox item id. Inbox functionality disabled.")
            return
        }

        var content: [String: Any] = [
            "notification": notification,
            "inboxItemId": inboxItemId,
            "inboxItemVisible": userInfo["inboxItemVisible"] as? Bool ?? false,
        ]

        if let expiresStr = userInfo["inboxItemExpires"] as? String,
           let inboxItemExpires = NotificareIsoDateUtils.parse(expiresStr)
        {
            content["inboxItemExpires"] = inboxItemExpires
        }

        // Notify the inbox to add this item.
        NotificationCenter.default.post(
            name: addInboxItemNotification,
            object: nil,
            userInfo: content
        )
    }

    static func markItemAsRead(userInfo: [AnyHashable: Any]) {
        guard let inboxItemId = userInfo["inboxItemId"] as? String else {
            NotificareLogger.debug("Received a notification payload without an inbox item id. Inbox functionality disabled.")
            return
        }

        NotificationCenter.default.post(
            name: readInboxItemNotification,
            object: nil,
            userInfo: [
                "inboxItemId": inboxItemId,
            ]
        )
    }
}
