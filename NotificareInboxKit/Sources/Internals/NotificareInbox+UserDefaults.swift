//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificareUserDefaults {
    static var currentBadge: Int {
        get {
            UserDefaults.standard.integer(forKey: "\(Key.currentBadge.rawValue)")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "\(Key.currentBadge.rawValue)")
        }
    }
}
