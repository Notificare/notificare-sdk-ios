//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareNotification {
    public var requiresViewController: Bool {
        guard let type = NotificareNotification.NotificationType(rawValue: type) else {
            return true
        }

        switch type {
        case .none, .passbook, .alert, .rate, .store, .urlScheme, .inAppBrowser:
            return false
        default:
            return true
        }
    }
}
