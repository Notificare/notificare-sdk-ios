//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct FetchProducts: Decodable {
        internal let products: [NotificareInternals.PushAPI.Models.Product]
    }
}
