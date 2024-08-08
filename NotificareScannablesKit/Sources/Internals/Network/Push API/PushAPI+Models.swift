//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareInternals.PushAPI.Models {
    internal struct Scannable: Decodable, Equatable {
        internal let _id: String
        internal let name: String
        internal let type: String
        internal let tag: String
        internal let data: ScannableData?

        internal struct ScannableData: Decodable, Equatable {
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
