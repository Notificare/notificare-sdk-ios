//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct Assets: Decodable {
        internal let assets: [NotificareInternals.PushAPI.Models.Asset]
    }
}
