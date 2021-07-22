//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct Pass: Decodable {
        let pass: NotificareInternals.PushAPI.Models.Pass
    }
}
