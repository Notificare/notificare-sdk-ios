//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

public extension NotificareNotification {
    var requiresViewController: Bool {
        guard let type = NotificareNotification.NotificationType(rawValue: type) else {
            return true
        }

        switch type {
        case .none, .passbook, .alert, .rate, .store, .urlScheme, .inAppBrowser:
            return false

        case .urlResolver:
            let result = NotificationUrlResolver.resolve(self)

            switch result {
            case .none, .urlScheme, .inAppBrowser:
                return false
            case .webView:
                return true
            }

        default:
            return true
        }
    }
}
