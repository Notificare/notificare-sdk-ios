//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import NotificareKit
import NotificareUtilitiesKit

extension InboxItemEntity {
    internal var expired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }

    internal convenience init(from model: NotificareInboxItem, visible: Bool, context: NSManagedObjectContext) throws {
        let encoder = JSONUtils.jsonEncoder

        self.init(context: context)
        id = model.id
        notificationId = model.notification.id

        do {
            notification = try encoder.encode(model.notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        time = model.time
        opened = model.opened
        self.visible = visible
        expires = model.expires
    }

    internal func setNotification(_ notification: NotificareNotification) throws {
        let encoder = JSONUtils.jsonEncoder

        do {
            self.notification = try encoder.encode(notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }
    }

    internal func toModel() throws -> NotificareInboxItem {
        let decoder = JSONUtils.jsonDecoder

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
