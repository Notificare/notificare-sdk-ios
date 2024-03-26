//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal enum LocalStorage {
    private enum Keys: String {
        case currentBadge = "re.notifica.inbox.local_storage.current_badge"
    }

    internal static var currentBadge: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.currentBadge.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.currentBadge.rawValue)
        }
    }
}
