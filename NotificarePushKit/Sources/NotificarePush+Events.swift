//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareEventsModule {
    public func logNotificationReceived(_ id: String) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.notification.Receive", notificationId: id)
    }

    public func logNotificationInfluenced(_ id: String) async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.notification.Influenced", notificationId: id)
    }

    public func logPushRegistration() async throws {
        let this = self as! NotificareInternalEventsModule
        try await this.log("re.notifica.event.push.Registration", notificationId: nil)
    }
}
