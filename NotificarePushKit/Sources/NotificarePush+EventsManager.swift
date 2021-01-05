//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareEventsModule {
    func logNotificationReceived(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Receive", data: nil, for: notification.id)
    }

    func logNotificationOpen(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Open", data: nil, for: notification.id)
    }

    func logNotificationInfluenced(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Influenced", data: nil, for: notification.id)
    }
}
