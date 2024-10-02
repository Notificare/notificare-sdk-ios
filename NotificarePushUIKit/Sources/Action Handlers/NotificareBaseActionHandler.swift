//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareBaseActionHandler: NSObject {
    internal let notification: NotificareNotification
    internal let action: NotificareNotification.Action

    internal init(notification: NotificareNotification, action: NotificareNotification.Action) {
        self.notification = notification
        self.action = action
    }

    internal func execute() {}
}
