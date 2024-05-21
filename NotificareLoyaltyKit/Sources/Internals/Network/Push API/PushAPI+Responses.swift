//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal extension NotificareInternals.PushAPI.Responses {
    struct Pass: Decodable {
        internal let pass: NotificareInternals.PushAPI.Models.Pass
    }

    struct FetchPassbookTemplate: Decodable {
        internal let passbook: NotificareInternals.PushAPI.Models.Passbook
    }
}
