//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareEventsModule: AnyObject {
    // func logApplicationException(_ error: Error, _ completion: @escaping NotificareCallback<Void>)

    func logNotificationOpen(_ id: String, _ completion: @escaping NotificareCallback<Void>)

    func logNotificationOpen(_ id: String) async throws

    func logCustom(_ event: String, data: NotificareEventData?, _ completion: @escaping NotificareCallback<Void>)

    func logCustom(_ event: String, data: NotificareEventData?) async throws
}

public extension NotificareEventsModule {
    func logCustom(_ event: String, data: NotificareEventData? = nil, _ completion: @escaping NotificareCallback<Void>) {
        logCustom(event, data: data, completion)
    }

    func logCustom(_ event: String, data: NotificareEventData? = nil) async throws {
        try await logCustom(event, data: data)
    }
}

public protocol NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData?, sessionId: String?, notificationId: String?) async throws
}

public extension NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData? = nil, sessionId: String? = nil, notificationId: String? = nil) async throws {
        try await log(event, data: data, sessionId: sessionId, notificationId: notificationId)
    }
}
