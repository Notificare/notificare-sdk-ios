//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareEventsModule: AnyObject {
    func logApplicationInstall(_ completion: @escaping NotificareCallback<Void>)

    func logApplicationRegistration(_ completion: @escaping NotificareCallback<Void>)

    func logApplicationUpgrade(_ completion: @escaping NotificareCallback<Void>)

    func logApplicationOpen(_ completion: @escaping NotificareCallback<Void>)

    func logApplicationClose(sessionLength: Double, _ completion: @escaping NotificareCallback<Void>)

    // func logApplicationException(_ error: Error, _ completion: @escaping NotificareCallback<Void>)

    func logNotificationOpen(_ id: String, _ completion: @escaping NotificareCallback<Void>)

    func logCustom(_ event: String, data: NotificareEventData?, _ completion: @escaping NotificareCallback<Void>)
}

public extension NotificareEventsModule {
    func logCustom(_ event: String, data: NotificareEventData? = nil, _ completion: @escaping NotificareCallback<Void>) {
        logCustom(event, data: data, completion)
    }
}

public protocol NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData?, for notification: String?, _ completion: NotificareCallback<Void>)
}

public extension NotificareInternalEventsModule {
    func log(_ event: String, data: NotificareEventData? = nil, for notification: String? = nil, _ completion: NotificareCallback<Void>) {
        log(event, data: data, for: notification, completion)
    }
}
