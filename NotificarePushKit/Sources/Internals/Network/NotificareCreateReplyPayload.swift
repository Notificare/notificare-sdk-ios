//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

struct NotificareCreateReplyPayload: Encodable {
    let notificationId: String
    let deviceId: String
    let userId: String?
    let label: String
    let data: Data

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification"
        case deviceId = "deviceID"
        case userId = "userID"
        case label
        case data
    }
}

extension NotificareCreateReplyPayload {
    struct Data: Encodable {
        let target: String?
        let message: String?
        let media: String?
    }
}
