//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Product: Decodable {
        internal let _id: String
        internal let identifier: String
        internal let name: String
        internal let type: String
        internal let stores: [String]
    }
}
