//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public protocol NotificareScannablesDelegate: AnyObject {
    /// Called when an error occurs during a scannable session.
    ///
    /// - Parameters:
    ///   - notificareScannables: The NotificareScannables object instance.
    ///   - error: The ``Error`` that invalidated the scannable session.
    func notificare(_ notificareScannables: NotificareScannables, didInvalidateScannerSession error: Error)

    /// Called when a scannable item is detected during a scannable session.
    ///
    /// - Parameters:
    ///   - notificareScannables: The NotificareScannablesobject instance.
    ///   - scannable: The detected ``NotificareScannable`` object.
    func notificare(_ notificareScannables: NotificareScannables, didDetectScannable scannable: NotificareScannable)
}

extension NotificareScannablesDelegate {
    public func notificare(_: NotificareScannables, didInvalidateScannerSession _: Error) {}

    public func notificare(_: NotificareScannables, didDetectScannable _: NotificareScannable) {}
}
