//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareBaseActionHandler: NSObject {
    let notification: NotificareNotification
    let action: NotificareNotification.Action

    init(notification: NotificareNotification, action: NotificareNotification.Action) {
        self.notification = notification
        self.action = action
    }

    func execute() {}
}
