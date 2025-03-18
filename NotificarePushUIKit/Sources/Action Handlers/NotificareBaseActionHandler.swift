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

    internal func dismiss() {
        if let rootViewController = UIApplication.shared.rootViewController, rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true, completion: nil)
        } else {
            if sourceViewController is UIAlertController {
                UIApplication.shared.rootViewController?.dismiss(animated: true, completion: nil)
            } else {
                sourceViewController.dismiss(animated: true) {
                    self.sourceViewController.becomeFirstResponder()
                }
            }
        }
    }
}
