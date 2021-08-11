//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Region: Decodable {
        let _id: String
        let name: String
        let distance: Double
        let geometry: Geometry

        struct Geometry: Decodable {
            let type: String
            let coordinates: [Double]
        }
    }
}
