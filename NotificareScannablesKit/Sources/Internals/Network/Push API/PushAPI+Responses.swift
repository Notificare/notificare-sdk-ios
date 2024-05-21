//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct Scannable: Decodable {
        internal let scannable: NotificareInternals.PushAPI.Models.Scannable
    }
}
