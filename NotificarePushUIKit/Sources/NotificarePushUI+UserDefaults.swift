//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareUserDefaults {
    static var hasReviewedVersion: Bool {
        get {
            let version = NotificareUtils.applicationVersion
            return UserDefaults.standard.bool(forKey: "re.notifica.local.reviewed_\(version)")
        }
        set {
            let version = NotificareUtils.applicationVersion
            UserDefaults.standard.setValue(newValue, forKey: "re.notifica.local.reviewed_\(version)")
        }
    }
}
