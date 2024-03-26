//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct UserInboxNotification: Decodable {
        internal let notification: NotificareInternals.PushAPI.Models.Notification
    }
}
