//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareEventsModule {
    func logInAppMessageViewed(_ message: NotificareInAppMessage, _ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.inappmessage.View", data: ["message": message.id], completion)
    }

    func logInAppMessageActionClicked(_ message: NotificareInAppMessage, _ completion: @escaping NotificareCallback<Void>) {
        let this = self as! NotificareInternalEventsModule
        this.log("re.notifica.event.inappmessage.Action", data: ["message": message.id], completion)
    }
}
