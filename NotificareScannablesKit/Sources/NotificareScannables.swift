//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public protocol NotificareScannables: AnyObject {
    // MARK: Properties

    /// Specifies the delegate that handles scannables session events
    ///
    /// This property allows setting a delegate conforming to ``NotificareScannablesDelegate`` to respond to various scannables session events,
    /// such as such as when a scannable item is detected (either via NFC or QR code), or when an error occurs during the session.

    var delegate: NotificareScannablesDelegate? { get set }

    /// Indicates whether an NFC scannable session can be started on the current device.
    /// 
    /// Returns *true* if the device supports and is ready for starting an NFC scanning session, otherwise *false*.
    var canStartNfcScannableSession: Bool { get }

    // MARK: Methods

    /// Starts a scannable session, automatically selecting the best scanning method available.
    /// 
    /// If NFC is available, it starts an NFC-based scanning session. If NFC is not available, it defaults to starting
    /// a QR code scanning session.
    /// 
    ///  - Parameters:
    ///    - controller: The ``UIViewController`` in which to start the scannable session.
    func startScannableSession(controller: UIViewController)

    /// Starts an NFC scannable session.
    /// 
    /// Initiates an NFC-based scan, allowing the user to scan NFC tags. This will only function on devices that support NFC
    /// and have it enabled.
    func startNfcScannableSession()

    /// Starts a QR code scannable session.
    /// 
    /// Initiates a QR code-based scan using the device camera, allowing the user to scan QR codes.
    /// 
    /// - Parameters:
    ///   - controller: The ``UIViewController`` in which to start the scannable session.
    ///   - modal: A Boolean indicating whether the scanner should be presented modally (`true`) or embedded in the existing navigation flow (`false`).
    func startQrCodeScannableSession(controller: UIViewController, modal: Bool)

    /// Fetches a scannable item by its tag, with a callback.
    /// 
    /// - Parameters:
    ///   - tag: The tag identifier for the scannable item to be fetched.
    ///   - completion: A callback that will be invoked with the result of the fetch operation.
    func fetch(tag: String, _ completion: @escaping NotificareCallback<NotificareScannable>)

    /// Fetches a scannable item by its tag.
    /// 
    /// - Parameters:
    ///   - tag: The tag identifier for the scannable item to be fetched.
    /// - Returns: The ``NotificareScannable`` object corresponding to the provided tag.
    func fetch(tag: String) async throws -> NotificareScannable
}

extension NotificareScannables {
    /// Starts a QR code scannable session.
    /// 
    /// Initiates a QR code-based scan using the device camera, allowing the user to scan QR codes.
    /// 
    /// - Parameters:
    ///   - controller: The ``UIViewController`` in which to start the scannable session.
    ///   - modal: A Boolean indicating whether the scanner should be presented modally (`true`) or embedded in the existing navigation flow (`false`).
    public func startQrCodeScannableSession(controller: UIViewController, modal: Bool = false) {
        startQrCodeScannableSession(controller: controller, modal: modal)
    }
}
