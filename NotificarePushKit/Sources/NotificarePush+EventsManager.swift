//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension NotificareEventsModule {
    func logNotificationReceived(_ notification: NotificareNotification, _ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.notification.Receive", data: nil, for: notification.id, completion)
    }

    func logNotificationReceived(_ id: String, _ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.notification.Receive", data: nil, for: id, completion)
    }

    func logNotificationInfluenced(_ notification: NotificareNotification, _ completion: NotificareCallback<Void>? = nil) {
        log("re.notifica.event.notification.Influenced", data: nil, for: notification.id, completion)
    }
}
