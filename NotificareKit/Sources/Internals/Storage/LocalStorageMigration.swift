//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal struct LocalStorageMigration {
    var hasLegacyData: Bool {
        UserDefaults.standard.object(forKey: "notificareDeviceToken") != nil
    }

    func migrate() {
        if let deviceId = UserDefaults.standard.string(forKey: "notificareDeviceToken") {
            NotificareLogger.debug("Found v2 device stored.")

            let transport: NotificareTransport
            if let transportStr = UserDefaults.standard.string(forKey: "notificareDeviceTransport") {
                transport = NotificareTransport(rawValue: transportStr) ?? .notificare
            } else {
                transport = .notificare
            }

            let lastRegistered = UserDefaults.standard.value(forKey: "notificareDeviceLastRegistered") as? Date
                ?? Calendar.current.date(byAdding: .day, value: -7, to: Date())!

            let device = NotificareDevice(
                id: deviceId,
                userId: UserDefaults.standard.string(forKey: "notificareUserID"),
                userName: UserDefaults.standard.string(forKey: "notificareUserName"),
                timeZoneOffset: UserDefaults.standard.float(forKey: "notificareDeviceTimezone"),
                osVersion: UserDefaults.standard.string(forKey: "notificareOSVersion") ?? "",
                sdkVersion: UserDefaults.standard.string(forKey: "notificareSDKVersion") ?? "",
                appVersion: UserDefaults.standard.string(forKey: "notificareAppVersion") ?? "",
                deviceString: UserDefaults.standard.string(forKey: "notificareDeviceModel") ?? "",
                language: UserDefaults.standard.string(forKey: "notificareDeviceLanguage") ?? NotificareUtils.deviceLanguage,
                region: UserDefaults.standard.string(forKey: "notificareDeviceRegion") ?? NotificareUtils.deviceRegion,
                transport: transport,
                dnd: nil,
                userData: [:],
                lastRegistered: lastRegistered,
                backgroundAppRefresh: UserDefaults.standard.bool(forKey: "notificareBackgroundAppRefresh")
            )

            LocalStorage.device = device
        }

        if let language = UserDefaults.standard.string(forKey: "notificarePreferredLanguage") {
            NotificareLogger.debug("Found v2 language override stored.")
            LocalStorage.preferredLanguage = language
        }

        if let region = UserDefaults.standard.string(forKey: "notificarePreferredRegion") {
            NotificareLogger.debug("Found v2 region override stored.")
            LocalStorage.preferredRegion = region
        }

        // Signal each available module to migrate whatever data it needs.
        NotificareInternals.Module.allCases.forEach { module in
            module.instance?.migrate()
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
