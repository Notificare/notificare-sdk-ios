//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

internal struct ConsumerUserInboxResponse: Codable {
    internal let count: Int
    internal let unread: Int
    internal let items: [NotificareUserInboxItem]
}
