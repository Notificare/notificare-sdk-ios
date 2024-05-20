//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct InAppMessage: Decodable {
        internal let message: NotificareInternals.PushAPI.Models.Message
    }
}
