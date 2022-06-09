//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareCustomActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target) {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didReceiveCustomAction: url, in: self.action, for: self.notification)
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didExecuteAction: self.action, for: self.notification)
            }

            Notificare.shared.createNotificationReply(notification: notification, action: action) { _ in }
        } else {
            DispatchQueue.main.async {
                Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToExecuteAction: self.action, for: self.notification, error: ActionError.invalidUrl)
            }
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
