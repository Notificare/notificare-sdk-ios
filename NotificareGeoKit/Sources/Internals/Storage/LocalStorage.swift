//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

private let KEY_LOCATION_SERVICES_ENABLED = "re.notifica.geo.location_services_enabled"
private let KEY_CACHED_REGIONS = "re.notifica.geo.cached_regions"
private let KEY_MONITORED_REGIONS = "re.notifica.geo.monitored_regions"
private let KEY_MONITORED_BEACONS = "re.notifica.geo.monitored_beacons"

internal enum LocalStorage {
    static var locationServicesEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: KEY_LOCATION_SERVICES_ENABLED)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_LOCATION_SERVICES_ENABLED)
        }
    }

//    static var cachedRegions: [NotificareRegion]

    static var monitoredRegions: [NotificareRegion] {
        get {
            guard let data = UserDefaults.standard.object(forKey: KEY_MONITORED_REGIONS) as? Data else {
                return []
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode([NotificareRegion].self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the monitored regions.\n\(error)")

                // Remove the corrupted application from local storage.
                UserDefaults.standard.removeObject(forKey: KEY_MONITORED_REGIONS)
                UserDefaults.standard.synchronize()

                return []
            }
        }
        set {
            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: KEY_MONITORED_REGIONS)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the monitored regions.\n\(error)")
            }
        }
    }

//    static var monitoredBeacons: [String]
}
