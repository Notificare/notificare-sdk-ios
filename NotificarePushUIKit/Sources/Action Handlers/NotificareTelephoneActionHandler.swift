//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit

class NotificareTelephoneActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target), UIApplication.shared.canOpenURL(url) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    // [[self delegate] actionType:self didExecuteAction:[self action]];
                    NotificarePush.shared.submitNotificationActionReply(self.action, for: self.notification) { _ in }
                }
            }
        } else {
            // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:e];
        }
    }
}
