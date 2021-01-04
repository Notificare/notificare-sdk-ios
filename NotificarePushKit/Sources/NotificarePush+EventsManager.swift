//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareEventsModule {
    func logNotificationReceived(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Receive", data: ["notification": notification.id])
    }

    func logNotificationOpen(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Open", data: ["notification": notification.id])
    }

    func logNotificationInfluenced(_ notification: NotificareNotification) {
        log("re.notifica.event.notification.Influenced", data: ["notification": notification.id])
    }
}
