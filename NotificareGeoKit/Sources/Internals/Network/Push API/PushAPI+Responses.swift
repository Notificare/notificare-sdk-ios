//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct FetchRegions: Decodable {
        let regions: [NotificareInternals.PushAPI.Models.Region]
    }

    struct FetchBeacons: Decodable {
        let beacons: [NotificareInternals.PushAPI.Models.Beacon]
    }
}
