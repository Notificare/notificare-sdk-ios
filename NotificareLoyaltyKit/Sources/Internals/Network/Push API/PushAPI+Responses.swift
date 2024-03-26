//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct Pass: Decodable {
        internal let pass: NotificareInternals.PushAPI.Models.Pass
    }

    internal struct FetchPassbookTemplate: Decodable {
        internal let passbook: NotificareInternals.PushAPI.Models.Passbook
    }
}
