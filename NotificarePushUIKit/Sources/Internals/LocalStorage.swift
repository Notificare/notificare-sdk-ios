//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareUtilitiesKit

internal enum LocalStorage {
    private enum Keys: String {
        case reviewedVersion = "re.notifica.push_ui.local_storage.reviewed_version"
    }

    internal static var hasReviewedCurrentVersion: Bool {
        get {
            let version = Bundle.main.applicationVersion
            return UserDefaults.standard.bool(forKey: "\(Keys.reviewedVersion.rawValue)_\(version)")
        }
        set {
            let version = Bundle.main.applicationVersion
            UserDefaults.standard.setValue(newValue, forKey: "\(Keys.reviewedVersion.rawValue)_\(version)")
        }
    }
}
