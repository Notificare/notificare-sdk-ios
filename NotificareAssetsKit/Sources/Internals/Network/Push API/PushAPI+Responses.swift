//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct Assets: Decodable {
        internal let assets: [NotificareInternals.PushAPI.Models.Asset]
    }
}
