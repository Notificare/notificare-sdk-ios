//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public protocol NotificareScannables: AnyObject {
    // MARK: Properties

    var delegate: NotificareScannablesDelegate? { get set }

    var canStartNfcScannableSession: Bool { get }

    // MARK: Methods

    func startNfcScannableSession()

    func startQrCodeScannableSession(controller: UIViewController, modal: Bool)
}

public extension NotificareScannables {
    func startQrCodeScannableSession(controller: UIViewController, modal: Bool = false) {
        startQrCodeScannableSession(controller: controller, modal: modal)
    }
}
