//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData
import NotificareCore

extension InboxItemEntity {
    convenience init(from model: NotificareInboxItem, context: NSManagedObjectContext) {
        let encoder = NotificareUtils.jsonEncoder

        var attachmentData: Data?
        if let attachment = model.attachment {
            attachmentData = try! encoder.encode(attachment)
        }

        let encodableExtras = model.extra.mapValues { AnyCodable($0) }
        let extrasData = try! encoder.encode(encodableExtras)

        self.init(context: context)
        id = model.id
        notificationId = model.notificationId
        type = model.type
        time = model.time
        title = model.title
        subtitle = model.subtitle
        message = model.message
        attachment = attachmentData
        extra = extrasData
        opened = model.opened
        visible = model.visible
        expires = model.expires
    }

    func toModel() -> NotificareInboxItem {
        let decoder = NotificareUtils.jsonDecoder

        var attachment: NotificareInboxItem.Attachment?
        if let data = self.attachment {
            attachment = try! decoder.decode(NotificareInboxItem.Attachment.self, from: data)
        }

        var extras = [String: Any]()
        if let data = extra {
            let decoded = try! decoder.decode([String: AnyCodable].self, from: data)
            extras = decoded.mapValues { $0.value }
        }

        return NotificareInboxItem(
            id: id!,
            notificationId: notificationId!,
            type: type!,
            time: time!,
            title: title,
            subtitle: subtitle,
            message: message!,
            attachment: attachment,
            extra: extras,
            opened: opened,
            visible: visible,
            expires: expires
        )
    }
}
