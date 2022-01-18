//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDelegate: AnyObject {
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication)

    func notificareDidUnlaunch(_ notificare: Notificare)

    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice)
}

public extension NotificareDelegate {
    func notificare(_: Notificare, didRegisterDevice _: NotificareDevice) {}

    func notificareDidUnlaunch(_: Notificare) {}
}
