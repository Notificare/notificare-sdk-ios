//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareUserDefaults {
    public enum Key: String {
        // NotificareKit
        case currentDatabaseVersion = "re.notifica.local.currentDatabaseVersion"
        case preferredLanguage = "re.notifica.local.preferredLanguage"
        case preferredRegion = "re.notifica.local.preferredRegion"
        case registeredDevice = "re.notifica.local.registeredDevice"
        case crashReport = "re.notifica.local.crashReport"

        // NotificarePushUIKit
        case reviewedVersion = "re.notifica.local.reviewedVersion"

        // NotificareInboxKit
        case currentBadge = "re.notifica.local.currentBadge"
    }
}
