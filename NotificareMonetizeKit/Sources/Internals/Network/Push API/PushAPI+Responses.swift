//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct FetchProducts: Decodable {
        internal let products: [NotificareInternals.PushAPI.Models.Product]
    }
}
