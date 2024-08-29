//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

private let KEY_LOCATION_SERVICES_ENABLED = "re.notifica.geo.location_services_enabled"
private let KEY_BLUETOOTH_ENABLED = "re.notifica.geo.bluetooth_enabled"
private let KEY_ENTERED_REGIONS = "re.notifica.geo.entered_regions"
private let KEY_ENTERED_BEACONS = "re.notifica.geo.entered_regions"
private let KEY_MONITORED_REGIONS = "re.notifica.geo.monitored_regions"
private let KEY_MONITORED_BEACONS = "re.notifica.geo.monitored_beacons"
private let KEY_REGION_SESSIONS = "re.notifica.geo.region_sessions"
private let KEY_BEACON_SESSIONS = "re.notifica.geo.beacon_sessions"

internal enum LocalStorage {
    internal static var locationServicesEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: KEY_LOCATION_SERVICES_ENABLED)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_LOCATION_SERVICES_ENABLED)
        }
    }

    internal static var bluetoothEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: KEY_BLUETOOTH_ENABLED)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_BLUETOOTH_ENABLED)
        }
    }

    internal static var enteredRegions: Set<String> {
        get {
            let arr = UserDefaults.standard.stringArray(forKey: KEY_ENTERED_REGIONS) ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: KEY_ENTERED_REGIONS)
        }
    }

    internal static var enteredBeacons: Set<String> {
        get {
            let arr = UserDefaults.standard.stringArray(forKey: KEY_ENTERED_BEACONS) ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: KEY_ENTERED_BEACONS)
        }
    }

    internal static var monitoredRegions: [NotificareRegion] {
        get {
            guard let data = UserDefaults.standard.object(forKey: KEY_MONITORED_REGIONS) as? Data else {
                return []
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode([NotificareRegion].self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the monitored regions.", error: error)

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
                NotificareLogger.warning("Failed to encode the monitored regions.", error: error)
            }
        }
    }

    internal static var monitoredBeacons: Set<NotificareBeacon> {
        get {
            guard let data = UserDefaults.standard.object(forKey: KEY_MONITORED_BEACONS) as? Data else {
                return []
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                let arr = try decoder.decode([NotificareBeacon].self, from: data)
                return Set(arr)
            } catch {
                NotificareLogger.warning("Failed to decode the monitored beacons.", error: error)

                // Remove the corrupted beacons from local storage.
                UserDefaults.standard.removeObject(forKey: KEY_MONITORED_BEACONS)
                UserDefaults.standard.synchronize()

                return []
            }
        }
        set {
            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(Array(newValue))

                UserDefaults.standard.set(data, forKey: KEY_MONITORED_BEACONS)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the monitored beacons.", error: error)
            }
        }
    }

    internal static var regionSessions: [NotificareRegionSession] {
        get {
            guard let data = UserDefaults.standard.object(forKey: KEY_REGION_SESSIONS) as? Data else {
                return []
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode([NotificareRegionSession].self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the region sessions.", error: error)

                // Remove the corrupted application from local storage.
                UserDefaults.standard.removeObject(forKey: KEY_REGION_SESSIONS)
                UserDefaults.standard.synchronize()

                return []
            }
        }
        set {
            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: KEY_REGION_SESSIONS)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the region sessions.", error: error)
            }
        }
    }

    internal static var beaconSessions: [NotificareBeaconSession] {
        get {
            guard let data = UserDefaults.standard.object(forKey: KEY_BEACON_SESSIONS) as? Data else {
                return []
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode([NotificareBeaconSession].self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the beacon sessions.", error: error)

                // Remove the corrupted beacon sessions from local storage.
                UserDefaults.standard.removeObject(forKey: KEY_BEACON_SESSIONS)
                UserDefaults.standard.synchronize()

                return []
            }
        }
        set {
            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: KEY_BEACON_SESSIONS)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the beacon sessions.", error: error)
            }
        }
    }

    internal static func clear() {
        UserDefaults.standard.removeObject(forKey: KEY_LOCATION_SERVICES_ENABLED)
        UserDefaults.standard.removeObject(forKey: KEY_BLUETOOTH_ENABLED)
        UserDefaults.standard.removeObject(forKey: KEY_ENTERED_REGIONS)
        UserDefaults.standard.removeObject(forKey: KEY_ENTERED_BEACONS)
        UserDefaults.standard.removeObject(forKey: KEY_MONITORED_REGIONS)
        UserDefaults.standard.removeObject(forKey: KEY_MONITORED_BEACONS)
        UserDefaults.standard.removeObject(forKey: KEY_REGION_SESSIONS)
        UserDefaults.standard.removeObject(forKey: KEY_BEACON_SESSIONS)
    }
}
