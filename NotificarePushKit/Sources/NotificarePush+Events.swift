//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension NotificareEventsModule {
    func logNotificationReceived(_ id: String, _ completion: NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.notification.Receive", data: nil, for: id, completion)
    }

    func logNotificationInfluenced(_ id: String, _ completion: NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.notification.Influenced", data: nil, for: id, completion)
    }
}
