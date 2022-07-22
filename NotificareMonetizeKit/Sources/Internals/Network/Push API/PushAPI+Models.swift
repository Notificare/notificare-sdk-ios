//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Product: Decodable {
        let _id: String
        let identifier: String
        let name: String
        let type: String
        let stores: [String]
    }
}
