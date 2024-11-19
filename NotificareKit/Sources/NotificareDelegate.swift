//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDelegate: AnyObject {
    /// Called when the Notificare SDK is launched and fully ready.
    ///
    /// This method is triggered when the SDK has completed initialization and the ``NotificareApplication`` instance is available.
    /// Implement to perform actions when the SDK is ready.
    ///
    /// - Parameters:
    ///   - notificare: The Notificare object instance.
    ///   - application: The ``NotificareApplication`` containing the application's metadata.
    func notificare(_ notificare: Notificare, onReady application: NotificareApplication)

    /// Called when the Notificare SDK has been unlaunched.
    ///
    /// This method is triggered when the SDK has been shut down, indicating that it is no longer active.
    /// Implement this method to perform cleanup or update the app state based on the SDK's unlaunching.
    ///
    /// - Parameters:
    ///   - notificare: The Notificare object instance.
    func notificareDidUnlaunch(_ notificare: Notificare)

    /// Called when the device has been successfully registered with the Notificare platform.
    ///
    /// This method is triggered once after the device has been registered, and will only be triggered again when a new
    /// device is created after an unlaunch() is called.
    /// Implement this method to perform additional actions, such as updating user data or updating device attributes.
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
