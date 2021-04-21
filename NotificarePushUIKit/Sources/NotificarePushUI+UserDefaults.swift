//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareUserDefaults {
    static var hasReviewedCurrentVersion: Bool {
        get {
            let version = NotificareUtils.applicationVersion
            return UserDefaults.standard.bool(forKey: "\(Key.reviewedVersion.rawValue)_\(version)")
        }
        set {
            let version = NotificareUtils.applicationVersion
            UserDefaults.standard.setValue(newValue, forKey: "\(Key.reviewedVersion.rawValue)_\(version)")
        }
    }
}
