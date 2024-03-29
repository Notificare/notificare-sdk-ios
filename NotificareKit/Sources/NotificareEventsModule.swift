//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareEventsModule: AnyObject {
    // func logApplicationException(_ error: Error, _ completion: @escaping NotificareCallback<Void>)

    func logNotificationOpen(_ id: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func logNotificationOpen(_ id: String) async throws

    func logCustom(_ event: String, data: NotificareEventData?, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func logCustom(_ event: String, data: NotificareEventData?) async throws
}

public extension NotificareEventsModule {
    func logCustom(_ event: String, data: NotificareEventData? = nil, _ completion: @escaping NotificareCallback<Void>) {
        logCustom(event, data: data, completion)
    }

    @available(iOS 13.0, *)
    func logCustom(_ event: String, data: NotificareEventData? = nil) async throws {
        try await withCheckedThrowingContinuation { continuation in
            logCustom(event, data: data) { result in
                continuation.resume(with: result)
            }
        }
    }
}

public protocol NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData?, sessionId: String?, notificationId: String?, _ completion: @escaping NotificareCallback<Void>)
}

public extension NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData? = nil, sessionId: String? = nil, notificationId: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        log(event, data: data, sessionId: sessionId, notificationId: notificationId, completion)
    }
}
