//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import PassKit
import UIKit

public protocol NotificareLoyalty: AnyObject {
    // MARK: Methods

    func present(pass: NotificarePass, in controller: UIViewController)

    func fetchPass(serial: String, _ completion: @escaping NotificareCallback<NotificarePass>)

    func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>)
}
