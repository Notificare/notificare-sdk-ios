//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDelegate: AnyObject {
    /// Called when the Notificare SDK is fully ready and the application metadata is available.
    ///
    /// - Parameters:
    ///   - notificare: The Notificare object instance.
    ///   - application: The ``NotificareApplication`` containing the application's metadata.
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication)

    /// Called when the Notificare SDK has been unlaunched.
    ///
    /// - Parameters:
    ///   - notificare: The Notificare object instance.
    func notificareDidUnlaunch(_ notificare: Notificare)

    /// Called when the device has been successfully registered with the Notificare platform.
    ///
    /// - Parameters:
    ///   - notificare: The Notificare object instance.
    ///   - device: The registered ``NotificareDevice`` instance representing the device's registration details.
    func notificare(_ notificare: Notificare, didRegisterDevice device: NotificareDevice)
}

extension NotificareDelegate {
    public func notificare(_: Notificare, didRegisterDevice _: NotificareDevice) {}

    public func notificareDidUnlaunch(_: Notificare) {}
}
