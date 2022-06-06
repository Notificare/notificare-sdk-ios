//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension NotificareEventsModule {
    func logNotificationReceived(_ id: String, _ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.notification.Receive", notificationId: id, completion)
    }

    func logNotificationInfluenced(_ id: String, _ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.notification.Influenced", notificationId: id, completion)
    }

    func logPushRegistration(_ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.push.Registration", notificationId: nil, completion)
    }
}
