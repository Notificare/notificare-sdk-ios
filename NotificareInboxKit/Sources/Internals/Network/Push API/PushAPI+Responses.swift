//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct RemoteInbox: Decodable {
        let inboxItems: [NotificareInternals.PushAPI.Models.RemoteInboxItem]
        let count: Int
        let unread: Int
    }
}
