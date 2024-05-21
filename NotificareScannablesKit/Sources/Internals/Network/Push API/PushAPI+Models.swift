//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension NotificareInternals.PushAPI.Models {
    struct Scannable: Decodable {
        internal let _id: String
        internal let name: String
        internal let type: String
        internal let tag: String
        internal let data: ScannableData?

        internal struct ScannableData: Decodable {
            internal let notification: NotificareInternals.PushAPI.Models.Notification?
        }

        internal func toModel() -> NotificareScannable {
            NotificareScannable(
                id: _id,
                name: name,
                tag: tag,
                type: type,
                notification: data?.notification?.toModel()
            )
        }
    }
}
