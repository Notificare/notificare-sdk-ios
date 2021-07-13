//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Responses {
    struct Assets: Decodable {
        let assets: [PushAPI.Models.Asset]
    }
}
