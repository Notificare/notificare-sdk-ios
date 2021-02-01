//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

struct NotificareInboxResponse: Decodable {
    let inboxItems: [NotificareInboxItem]
    let count: Int
    let unread: Int
}
