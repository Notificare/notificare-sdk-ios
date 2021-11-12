//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public protocol NotificarePushUI: AnyObject {
    // MARK: Properties

    var delegate: NotificarePushUIDelegate? { get set }

    // MARK: Methods

    func presentNotification(_ notification: NotificareNotification, in controller: UIViewController)

    func presentAction(_ action: NotificareNotification.Action, for notification: NotificareNotification, in controller: UIViewController)
}
