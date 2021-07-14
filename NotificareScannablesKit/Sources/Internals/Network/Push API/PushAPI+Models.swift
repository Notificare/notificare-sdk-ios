//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

internal extension PushAPI.Models {
    struct Scannable: Decodable {
        let _id: String
        let name: String
        let type: String
        let tag: String
//        let data: ScannableData?
//
//        struct ScannableData: Decodable {
//            let notification: NotificareKit.PushAPI.Models.Notification?
//        }

        func toModel() -> NotificareScannable {
            NotificareScannable(
                id: _id,
                name: name,
                tag: tag,
                type: type,
                notification: nil // data?.notification?.toModel()
            )
        }
    }
}
