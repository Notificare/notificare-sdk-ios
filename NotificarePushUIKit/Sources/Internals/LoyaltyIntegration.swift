//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

private let PASS_RECEIVED_NOTIFICATION = NSNotification.Name(rawValue: "NotificareLoyaltyKit.PassReceived")

internal class LoyaltyIntegration {
    private init() {}

    static func onPassReceived(in notification: NotificareNotification, controller: UIViewController) {
        NotificationCenter.default.post(
            name: PASS_RECEIVED_NOTIFICATION,
            object: nil,
            userInfo: [
                "notification": notification,
                "viewController": controller,
            ]
        )
    }
}
