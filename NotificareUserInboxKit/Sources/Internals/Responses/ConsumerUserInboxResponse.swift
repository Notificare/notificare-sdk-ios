//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

internal struct ConsumerUserInboxResponse: Codable {
    let count: Int
    let unread: Int
    let items: [NotificareUserInboxItem]
}
