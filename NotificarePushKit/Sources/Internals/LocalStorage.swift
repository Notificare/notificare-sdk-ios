//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

enum LocalStorage {
    private enum Keys: String {
        case remoteNotificationsEnabled = "re.notifica.push.local_storage.remote_notifications_enabled"
    }

    static var remoteNotificationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.remoteNotificationsEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.remoteNotificationsEnabled.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
