//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public protocol NotificareScannablesDelegate: AnyObject {
    func notificare(_ notificareScannables: NotificareScannables, didInvalidateScannerSession error: Error)

    func notificare(_ notificareScannables: NotificareScannables, didDetectScannable scannable: NotificareScannable)
}

extension NotificareScannablesDelegate {
    public func notificare(_: NotificareScannables, didInvalidateScannerSession _: Error) {}

    public func notificare(_: NotificareScannables, didDetectScannable _: NotificareScannable) {}
}
