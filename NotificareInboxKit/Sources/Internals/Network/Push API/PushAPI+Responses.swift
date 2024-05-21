//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct RemoteInbox: Decodable {
        internal let inboxItems: [NotificareInternals.PushAPI.Models.RemoteInboxItem]
        internal let count: Int
        internal let unread: Int
    }
}
