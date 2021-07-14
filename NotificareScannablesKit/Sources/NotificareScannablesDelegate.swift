//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public protocol NotificareScannablesDelegate: AnyObject {
    func notificare(_ notificareScannables: NotificareScannables, didStartScanner scanner: UIViewController)

    func notificare(_ notificareScannables: NotificareScannables, didInvalidateScannerSession error: Error)

    func notificare(_ notificareScannables: NotificareScannables, didDetectScannable scannable: NotificareScannable)
}

public extension NotificareScannablesDelegate {
    func notificare(_: NotificareScannables, didStartScanner _: UIViewController) {}

    func notificare(_: NotificareScannables, didInvalidateScannerSession _: Error) {}

    func notificare(_: NotificareScannables, didDetectScannable _: NotificareScannable) {}
}
