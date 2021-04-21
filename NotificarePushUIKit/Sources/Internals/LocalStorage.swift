//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

enum LocalStorage {
    private enum Keys: String {
        case reviewedVersion = "re.notifica.push_ui.local_storage.reviewed_version"
    }

    static var hasReviewedCurrentVersion: Bool {
        get {
            let version = NotificareUtils.applicationVersion
            return UserDefaults.standard.bool(forKey: "\(Keys.reviewedVersion.rawValue)_\(version)")
        }
        set {
            let version = NotificareUtils.applicationVersion
            UserDefaults.standard.setValue(newValue, forKey: "\(Keys.reviewedVersion.rawValue)_\(version)")
        }
    }
}
