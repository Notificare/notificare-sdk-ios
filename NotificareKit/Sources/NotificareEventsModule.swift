//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareEventsModule: AnyObject {
    // func logApplicationException(_ error: Error, _ completion: @escaping NotificareCallback<Void>)

    /// Logs in Notificare when a notification has been opened by the user, with a callback.
    ///
    /// This function logs in Notificare the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the opened notification.
    ///   - completion: A callback that will be invoked with the result of the log notification open operation.
    func logNotificationOpen(_ id: String, _ completion: @escaping NotificareCallback<Void>)

    /// Logs in Notificare when a notification has been opened by the user.
    ///
    /// This function logs in Notificare the opening of a notification, enabling insight into user engagement with
    /// specific notifications.
    ///
    /// - Parameter id: The unique identifier of the opened notification.
    func logNotificationOpen(_ id: String) async throws

    /// Logs in Notificare a custom event in the application, with a callback.
    ///
    /// This function allows logging, in Notificare, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    ///   - completion: A callback that will be invoke with the result of the log custom operation.
    func logCustom(_ event: String, data: NotificareEventData?, _ completion: @escaping NotificareCallback<Void>)

    /// Logs in Notificare a custom event in the application.
    ///
    /// This function allows logging, in Notificare, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    func logCustom(_ event: String, data: NotificareEventData?) async throws
}

extension NotificareEventsModule {
    /// Logs in Notificare a custom event in the application, with a callback.
    ///
    /// This function allows logging, in Notificare, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    ///   - completion: A callback that will be invoke with the result of the log custom operation.
    public func logCustom(_ event: String, data: NotificareEventData? = nil, _ completion: @escaping NotificareCallback<Void>) {
        logCustom(event, data: data, completion)
    }

    /// Logs in Notificare a custom event in the application.
    ///
    /// This function allows logging, in Notificare, of application-specific events, optionally associating structured
    /// data for more detailed event tracking and analysis.
    ///
    /// - Parameters:
    ///   - event: The name of the custom event to log.
    ///   - data: Optional structured event data for further details.
    public func logCustom(_ event: String, data: NotificareEventData? = nil) async throws {
        try await logCustom(event, data: data)
    }
}

public protocol NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData?, sessionId: String?, notificationId: String?) async throws
}

extension NotificareInternalEventsModule {
    public func log(_ event: String, data: NotificareEventData? = nil, sessionId: String? = nil, notificationId: String? = nil) async throws {
        try await log(event, data: data, sessionId: sessionId, notificationId: notificationId)
    }
}
