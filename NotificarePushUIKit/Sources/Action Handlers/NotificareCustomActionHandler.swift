//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit

class NotificareCustomActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target) {
//            [[self delegate] actionType:self shouldPerformSelectorWithURL:url inAction:[self action]];
//            [[self delegate] actionType:self didExecuteAction:[self action]];
            NotificarePush.shared.submitNotificationActionReply(action, for: notification) { _ in }
        } else {
            // [[self delegate] actionType:self didFailToExecuteAction:[self action] withError:e];
        }
    }
}
