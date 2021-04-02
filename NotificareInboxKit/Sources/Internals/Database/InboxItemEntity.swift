//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import NotificareCore
import NotificareKit

extension InboxItemEntity {
    convenience init(from model: NotificareInboxItem, context: NSManagedObjectContext) {
        let encoder = NotificareUtils.jsonEncoder

        self.init(context: context)
        id = model.id
        notificationId = model.notification.id
        notification = try! encoder.encode(model.notification)
        time = model.time
        opened = model.opened
        visible = model.visible
        expires = model.expires
    }

    func setNotification(_ notification: NotificareNotification) {
        let encoder = NotificareUtils.jsonEncoder
        self.notification = try! encoder.encode(notification)
    }

    func toModel() -> NotificareInboxItem {
        let decoder = NotificareUtils.jsonDecoder

        return NotificareInboxItem(
            id: id!,
            notification: try! decoder.decode(NotificareNotification.self, from: notification!),
            time: time!,
            opened: opened,
            visible: visible,
            expires: expires
        )
    }
}
