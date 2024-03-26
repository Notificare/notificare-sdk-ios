//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificareInternals.PushAPI.Responses {
    internal struct InAppMessage: Decodable {
        internal let message: NotificareInternals.PushAPI.Models.Message
    }
}
