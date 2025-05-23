//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal struct LocalInboxItem {
    internal let id: String
    internal var notification: NotificareNotification
    internal let time: Date
    internal var opened: Bool
    internal let visible: Bool
    internal let expires: Date?

    internal var isExpired: Bool {
        guard let expires else {
            return false
        }

        return expires <= Date()
    }
}
