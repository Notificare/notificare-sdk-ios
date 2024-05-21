//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Models {
    internal struct Product: Decodable {
        internal let _id: String
        internal let identifier: String
        internal let name: String
        internal let type: String
        internal let stores: [String]
    }
}
