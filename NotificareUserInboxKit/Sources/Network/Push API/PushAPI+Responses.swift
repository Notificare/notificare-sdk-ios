//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct UserInboxNotification: Decodable {
        let notification: NotificareInternals.PushAPI.Models.Notification
    }
}
