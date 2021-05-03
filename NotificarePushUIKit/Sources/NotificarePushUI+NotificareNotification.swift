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
        case .none, .passbook, .rate, .urlScheme:
            return false
        default:
            return true
        }
    }
}
