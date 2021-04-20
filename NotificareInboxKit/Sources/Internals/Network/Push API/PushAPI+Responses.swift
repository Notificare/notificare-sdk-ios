//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Responses {
    struct RemoteInbox: Decodable {
        let inboxItems: [PushAPI.Models.RemoteInboxItem]
        let count: Int
        let unread: Int
    }
}
