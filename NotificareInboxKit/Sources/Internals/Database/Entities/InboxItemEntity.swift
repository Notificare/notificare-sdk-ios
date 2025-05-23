//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import NotificareKit
import NotificareUtilitiesKit

extension InboxItemEntity {
    internal convenience init(from item: LocalInboxItem, context: NSManagedObjectContext) throws {
        let encoder = JSONEncoder.notificare

        self.init(context: context)
        id = item.id
        notificationId = item.notification.id

        do {
            notification = try encoder.encode(item.notification)
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }

        time = item.time
        opened = item.opened
        visible = item.visible
        expires = item.expires
    }

    internal func setNotification(_ notification: NotificareNotification) throws {
        let encoder = JSONEncoder.notificare

        do {
            self.notification = try encoder.encode(notification)
            self.notificationId = notification.id
        } catch {
            throw InboxDatabaseError.invalidArgument("notification", cause: error)
        }
    }

    internal func toLocal() throws -> LocalInboxItem {
        let decoder = JSONDecoder.notificare

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

        return LocalInboxItem(
            id: id,
            notification: notification,
            time: time,
            opened: opened,
            visible: visible,
            expires: expires
        )
    }
}
