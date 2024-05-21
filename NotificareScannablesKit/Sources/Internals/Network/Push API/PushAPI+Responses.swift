//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct Scannable: Decodable {
        internal let scannable: NotificareInternals.PushAPI.Models.Scannable
    }
}
