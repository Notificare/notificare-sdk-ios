//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import Foundation

extension NotificareInboxItem {
    internal var isExpired: Bool {
        if let expiresAt = expires {
            return expiresAt <= Date()
        }

        return false
    }
}
