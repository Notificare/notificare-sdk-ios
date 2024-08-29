//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal enum LocalStorage {
    private enum Keys: String {
        case migrated = "re.notifica.local_storage.migrated"
        case application = "re.notifica.local_storage.application"
        case device = "re.notifica.local_storage.device"
        case preferredLanguage = "re.notifica.local_storage.preferred_language"
        case preferredRegion = "re.notifica.local_storage.preferred_region"
        case crashReport = "re.notifica.local_storage.crash_report"
        case currentDatabaseVersion = "re.notifica.local_storage.current_database_version"
        case deferredLinkChecked = "re.notifica.preferences.deferred_link_checked"
    }

    internal static var migrated: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.migrated.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.migrated.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var application: NotificareApplication? {
        get {
            guard let data = UserDefaults.standard.object(forKey: Keys.application.rawValue) as? Data else {
                return nil
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode(NotificareApplication.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored device.", error: error)

                // Remove the corrupted application from local storage.
                UserDefaults.standard.removeObject(forKey: Keys.application.rawValue)
                UserDefaults.standard.synchronize()

                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: Keys.application.rawValue)
                return
            }

            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: Keys.application.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the stored application.", error: error)
            }
        }
    }

    internal static var device: StoredDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: Keys.device.rawValue) as? Data else {
                return nil
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode(StoredDevice.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored device.", error: error)

                // Remove the corrupted device from local storage.
                settings.removeObject(forKey: Keys.device.rawValue)
                settings.synchronize()

                return nil
            }
        }
        set {
            let settings = UserDefaults.standard
            guard let newValue = newValue else {
                settings.removeObject(forKey: Keys.device.rawValue)
                return
            }

            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                settings.set(data, forKey: Keys.device.rawValue)
                settings.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the stored device.", error: error)
            }
        }
    }

    internal static var preferredLanguage: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.preferredLanguage.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.preferredLanguage.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var preferredRegion: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.preferredRegion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.preferredRegion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var crashReport: NotificareEvent? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.crashReport.rawValue) else {
                return nil
            }

            do {
                return try NotificareUtils.jsonDecoder.decode(NotificareEvent.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored crash report.", error: error)

                // Remove the corrupted crash report from local storage.
                UserDefaults.standard.removeObject(forKey: Keys.crashReport.rawValue)
                UserDefaults.standard.synchronize()

                return nil
            }
        }
        set {
            guard let event = newValue else {
                UserDefaults.standard.removeObject(forKey: Keys.crashReport.rawValue)
                UserDefaults.standard.synchronize()
                return
            }

            do {
                let data = try NotificareUtils.jsonEncoder.encode(event)
                UserDefaults.standard.set(data, forKey: Keys.crashReport.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the stored crash report.", error: error)
            }
        }
    }

    internal static var currentDatabaseVersion: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.currentDatabaseVersion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.currentDatabaseVersion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var deferredLinkChecked: Bool? {
        get {
            if UserDefaults.standard.object(forKey: Keys.deferredLinkChecked.rawValue) == nil {
                return nil
            }

            return UserDefaults.standard.bool(forKey: Keys.deferredLinkChecked.rawValue)
        }
        set {
            if let newValue {
                UserDefaults.standard.setValue(newValue, forKey: Keys.deferredLinkChecked.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.deferredLinkChecked.rawValue)
            }
        }
    }

    internal static func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.migrated.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.application.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.device.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.preferredLanguage.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.preferredRegion.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.crashReport.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.currentDatabaseVersion.rawValue)
        UserDefaults.standard.removeObject(forKey: Keys.deferredLinkChecked.rawValue)
    }
}
