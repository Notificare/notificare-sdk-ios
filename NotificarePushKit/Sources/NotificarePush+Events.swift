//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension NotificareEventsModule {
    func logNotificationReceived(_ id: String) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.notification.Receive", notificationId: id)
    }

    func logNotificationInfluenced(_ id: String) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.notification.Influenced", notificationId: id)
    }

    func logPushRegistration() async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.push.Registration", notificationId: nil)
    }
}
