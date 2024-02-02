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

    @available(iOS 13.0, *)
    func fetchPass(serial: String) async throws -> NotificarePass

    func fetchPass(barcode: String, _ completion: @escaping NotificareCallback<NotificarePass>)

    @available(iOS 13.0, *)
    func fetchPass(barcode: String) async throws -> NotificarePass
}
