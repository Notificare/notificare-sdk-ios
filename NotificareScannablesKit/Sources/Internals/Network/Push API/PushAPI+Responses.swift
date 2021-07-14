//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension PushAPI.Responses {
    struct Scannable: Decodable {
        let scannable: PushAPI.Models.Scannable
    }
}
