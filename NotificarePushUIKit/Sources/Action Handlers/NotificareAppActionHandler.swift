//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareAppActionHandler: NotificareBaseActionHandler {
    override func execute() {
        if let target = action.target, let url = URL(string: target), UIApplication.shared.canOpenURL(url) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:]) { _ in
                    NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didExecuteAction: self.action, for: self.notification)
                    Notificare.shared.createNotificationReply(notification: self.notification, action: self.action) { _ in }
                }
            }
        } else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToExecuteAction: action, for: notification, error: ActionError.unsupportedUrlScheme)
        }
    }
}

public extension NotificareAppActionHandler {
    enum ActionError: LocalizedError {
        case unsupportedUrlScheme

        public var errorDescription: String? {
            switch self {
            case .unsupportedUrlScheme:
                return "The app cannot open this URL Scheme."
            }
        }
    }
}
