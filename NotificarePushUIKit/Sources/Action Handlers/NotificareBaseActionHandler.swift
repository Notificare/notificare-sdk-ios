//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareBaseActionHandler: NSObject {
    internal let notification: NotificareNotification
    internal let action: NotificareNotification.Action
    internal let sourceViewController: UIViewController

    internal init(notification: NotificareNotification, action: NotificareNotification.Action, sourceViewController: UIViewController) {
        self.notification = notification
        self.action = action
        self.sourceViewController = sourceViewController
    }

    internal func execute() {}
}
