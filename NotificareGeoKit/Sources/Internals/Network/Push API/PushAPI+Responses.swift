//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct FetchRegions: Decodable {
        internal let regions: [NotificareInternals.PushAPI.Models.Region]
    }

    internal struct FetchBeacons: Decodable {
        internal let beacons: [NotificareInternals.PushAPI.Models.Beacon]
    }
}
