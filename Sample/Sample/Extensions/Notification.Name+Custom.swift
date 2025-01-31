//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation

extension Notification.Name {
    // Core
    internal static let notificareStatus = Notification.Name(rawValue: "app.notificare_launched")

    // Push
    internal static let notificationSettingsChanged = Notification.Name(rawValue: "app.notification_settings_changed")

    // Geo
    internal static let beaconsRanged = Notification.Name(rawValue: "app.beacons_ranged")
}
