//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareSystemNotification {
    public let id: String?
    public let type: String
    public let extras: [AnyHashable: Any]

    init(userInfo: [AnyHashable: Any]) {
        id = userInfo["id"] as? String
        type = userInfo["systemType"] as! String

        let ignoreKeys = ["aps", "system", "systemType", "attachment", "notificationId", "id", "x-sender"]
        extras = userInfo.filter { (entry) -> Bool in
            let key = entry.key as? String ?? ""
            return !ignoreKeys.contains(key)
        }
    }
}
