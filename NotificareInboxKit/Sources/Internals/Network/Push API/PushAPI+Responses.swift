//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct RemoteInbox: Decodable {
        internal let inboxItems: [NotificareInternals.PushAPI.Models.RemoteInboxItem]
        internal let count: Int
        internal let unread: Int
    }
}
