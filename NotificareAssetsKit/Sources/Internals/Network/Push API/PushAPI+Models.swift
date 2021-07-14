//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Asset: Decodable {
        let _id: String
        let key: String?
        let title: String
        let description: String?
        let extra: AnyCodable?
        let button: Button?
        let metaData: MetaData?

        struct Button: Decodable {
            let label: String?
            let action: String?
        }

        struct MetaData: Decodable {
            let originalFileName: String
            let contentType: String
            let contentLength: Int
        }
    }
}
