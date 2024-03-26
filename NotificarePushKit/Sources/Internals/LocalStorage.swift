//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal enum LocalStorage {
    private enum Keys: String {
        case remoteNotificationsEnabled = "re.notifica.push.local_storage.remote_notifications_enabled"
        case allowedUI = "re.notifica.push.local_storage.allowed_ui"
        case firstRegistration = "re.notifica.push.local_storage.first_registration"
    }

    internal static var remoteNotificationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.remoteNotificationsEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.remoteNotificationsEnabled.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var allowedUI: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.allowedUI.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.allowedUI.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var firstRegistration: Bool {
        get {
            if UserDefaults.standard.value(forKey: Keys.firstRegistration.rawValue) == nil {
                return true
            }

            return UserDefaults.standard.bool(forKey: Keys.firstRegistration.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.firstRegistration.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
