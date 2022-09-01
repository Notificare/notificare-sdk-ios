//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct InAppMessage: Decodable {
        let message: NotificareInternals.PushAPI.Models.Message
    }
}
