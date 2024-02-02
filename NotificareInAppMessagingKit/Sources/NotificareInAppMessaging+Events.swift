//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareEventsModule {
    func logInAppMessageViewed(_ message: NotificareInAppMessage) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.inappmessage.View", data: ["message": message.id])
    }

    func logInAppMessageActionClicked(_ message: NotificareInAppMessage, action: NotificareInAppMessage.ActionType) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log(
            "re.notifica.event.inappmessage.Action",
            data: [
                "message": message.id,
                "action": action.rawValue,
            ]
        )
    }
}
