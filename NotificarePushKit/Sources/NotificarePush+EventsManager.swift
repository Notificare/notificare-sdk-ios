//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareEventsModule {
    func logNotificationReceived(_ notification: NotificareNotification, _ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.notification.Receive", data: nil, for: notification.id, completion)
    }

    func logNotificationInfluenced(_ notification: NotificareNotification, _ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.notification.Influenced", data: nil, for: notification.id, completion)
    }
}
