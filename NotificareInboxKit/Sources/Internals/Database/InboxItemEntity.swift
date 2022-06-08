//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import NotificareKit

internal extension InboxItemEntity {
    var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }

    convenience init(from model: NotificareInboxItem, visible: Bool, context: NSManagedObjectContext) {
        let encoder = NotificareUtils.jsonEncoder

        self.init(context: context)
        id = model.id
        notificationId = model.notification.id
        notification = try! encoder.encode(model.notification)
        time = model.time
        opened = model.opened
        self.visible = visible
        expires = model.expires
    }

    func setNotification(_ notification: NotificareNotification) {
        let encoder = NotificareUtils.jsonEncoder
        self.notification = try! encoder.encode(notification)
    }

    func toModel() throws -> NotificareInboxItem {
        let decoder = NotificareUtils.jsonDecoder

        guard let id = id else {
            throw InboxDatabaseError.invalidArgument("id", cause: nil)
        }

        guard let notificationData = notification else {
            throw InboxDatabaseError.invalidArgument("notification", cause: nil)
        }

        let notification: NotificareNotification

        do {
            notification = try decoder.decode(NotificareNotification.self, from: notificationData)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        guard let time = time else {
            throw InboxDatabaseError.invalidArgument("time", cause: nil)
        }

        return NotificareInboxItem(
            id: id,
            notification: notification,
            time: time,
            opened: opened,
            expires: expires
        )
    }
}
