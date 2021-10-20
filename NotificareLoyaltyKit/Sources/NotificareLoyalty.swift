//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import PassKit
import UIKit

public protocol NotificareLoyalty: AnyObject {
    // MARK: Properties

    var delegate: NotificareLoyaltyDelegate? { get set }

    // MARK: Methods

    func present(_ notification: NotificareNotification, in controller: UIViewController)

    func present(_ pass: PKPass, in controller: UIViewController)

    func fetchPass(serial: String, _ completion: @escaping NotificareCallback<NotificarePass>)

    func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>)
}
