//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public class NotificareCustomActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target) {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, shouldPerformSelectorWithURL: url, in: action, for: notification)
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: action, for: notification)
            Notificare.shared.createNotificationReply(action, for: notification) { _ in }
        } else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.invalidUrl)
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
