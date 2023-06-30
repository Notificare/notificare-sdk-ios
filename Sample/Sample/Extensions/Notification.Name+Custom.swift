//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Core
    static let notificareStatus = Notification.Name(rawValue: "app.notificare_launched")

    // Push
    static let notificationSettingsChanged = Notification.Name(rawValue: "app.notification_settings_changed")

    // Inbox
    static let badgeUpdated = Notification.Name(rawValue: "app.badge_updated")
    static let inboxUpdated = Notification.Name(rawValue: "app.inbox_updated")

    // Geo
    static let beaconsRanged = Notification.Name(rawValue: "app.beacons_ranged")
}
