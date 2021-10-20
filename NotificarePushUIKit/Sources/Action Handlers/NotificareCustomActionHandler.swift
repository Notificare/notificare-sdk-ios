//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareCustomActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target) {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didReceiveCustomAction: url, in: action, for: notification)
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: action, for: notification)
            Notificare.shared.createNotificationReply(notification: notification, action: action) { _ in }
        } else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: action, for: notification, error: ActionError.invalidUrl)
        }
    }
}

public extension NotificareCustomActionHandler {
    enum ActionError: LocalizedError {
        case invalidUrl

        public var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "Invalid URL."
            }
        }
    }
}
