//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import UIKit

public class NotificareBrowserActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target), url.scheme != nil, url.host != nil, UIApplication.shared.canOpenURL(url) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: self.action, for: self.notification)
                    Notificare.shared.sendNotificationReply(self.action, for: self.notification) { _ in }
                }
            }
        } else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.invalidUrl)
        }
    }
}

public extension NotificareBrowserActionHandler {
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
