//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

internal struct LocalStorageMigration {
    internal var hasLegacyData: Bool {
        UserDefaults.standard.object(forKey: "notificareDeviceToken") != nil
    }

    internal func migrate() {
        if let deviceId = UserDefaults.standard.string(forKey: "notificareDeviceToken") {
            logger.debug("Found v2 device stored.")

            let device = StoredDevice(
                id: deviceId,
                userId: UserDefaults.standard.string(forKey: "notificareUserID"),
                userName: UserDefaults.standard.string(forKey: "notificareUserName"),
                timeZoneOffset: UserDefaults.standard.float(forKey: "notificareDeviceTimezone"),
                osVersion: UserDefaults.standard.string(forKey: "notificareOSVersion") ?? "",
                sdkVersion: UserDefaults.standard.string(forKey: "notificareSDKVersion") ?? "",
                appVersion: UserDefaults.standard.string(forKey: "notificareAppVersion") ?? "",
                deviceString: UserDefaults.standard.string(forKey: "notificareDeviceModel") ?? "",
                language: UserDefaults.standard.string(forKey: "notificareDeviceLanguage") ?? Locale.current.deviceLanguage(),
                region: UserDefaults.standard.string(forKey: "notificareDeviceRegion") ?? Locale.current.deviceRegion(),
                transport: UserDefaults.standard.string(forKey: "notificareDeviceTransport"),
                dnd: nil,
                userData: [:],
                backgroundAppRefresh: UserDefaults.standard.bool(forKey: "notificareBackgroundAppRefresh")
            )

            LocalStorage.device = device
        }

        if let language = UserDefaults.standard.string(forKey: "notificarePreferredLanguage") {
            logger.debug("Found v2 language override stored.")
            LocalStorage.preferredLanguage = language
        }

        if let region = UserDefaults.standard.string(forKey: "notificarePreferredRegion") {
            logger.debug("Found v2 region override stored.")
            LocalStorage.preferredRegion = region
        }

        // Signal each available module to migrate whatever data it needs.
        NotificareInternals.Module.allCases.forEach { module in
            module.klass?.instance.migrate()
        }

        // Remove all legacy properties.
        removeLegacyData()
    }

    private func removeLegacyData() {
        let legacyProperties = [
            "notificareNewRegistration",
            "notificareSessionDate",
            "notificareRegisteredForNotifications",
            "notificareAllowedUI",
            "notificareUserID",
            "notificareUserName",
            "notificareDeviceToken",
            "notificareDeviceTokenData",
            "notificareDeviceCountry",
            "notificareDeviceCountryCode",
            "notificareAllowedLocationServices",
            "notificareLocationServicesAuthStatus",
            "notificareLocationServicesAccuracyAuth",
            "notificareDeviceTimezone",
            "notificareOSVersion",
            "notificareSDKVersion",
            "notificareAppVersion",
            "notificareDeviceModel",
            "notificareDeviceLanguage",
            "notificareDeviceRegion",
            "notificareDeviceDnD",
            "notificareDeviceUserData",
            "notificareDeviceLatitude",
            "notificareDeviceLongitude",
            "notificareDeviceAltitude",
            "notificareDeviceAccuracy",
            "notificareDeviceCourse",
            "notificareDeviceFloor",
            "notificareDeviceSpeed",
            "notificareDeviceLastRegistered",
            "notificareBackgroundAppRefresh",
            "notificareBluetoothON",
            "notificareDeviceTransport",
            "notificarePreferredLanguage",
            "notificarePreferredRegion",
            "NotificareInboxBadge",
            "notificareCoreDataDB",
            "notificareMigrationCheckV2",
            "notificareMonitoredBeacons",
            "notificareMonitoredRegions",
            "notificareCachedBeacons",
            "notificareCachedRegions",
            "notificareRegionSessions",
            "notificareBeaconSessions",
            "notificareErrorStack",
            "notificareStoreReviewVersion",
        ]

        legacyProperties.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
