//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import UIKit

public protocol NotificareLoyaltyIntegration {
    var canPresentPasses: Bool { get }

    func present(notification: NotificareNotification, in viewController: UIViewController)
}
