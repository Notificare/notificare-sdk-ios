//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

enum LocalStorage {
    private enum Keys: String {
        case device = "re.notifica.local_storage.device"
        case preferredLanguage = "re.notifica.local_storage.preferred_language"
        case preferredRegion = "re.notifica.local_storage.preferred_region"
        case crashReport = "re.notifica.local_storage.crash_report"
        case currentDatabaseVersion = "re.notifica.local_storage.current_database_version"
    }

    static var device: NotificareDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: Keys.device.rawValue) as? Data else {
                return nil
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode(NotificareDevice.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored device.\n\(error)")
                
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
                NotificareLogger.warning("Failed to encode the stored device.\n\(error)")
            }
        }
    }

    static var preferredLanguage: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.preferredLanguage.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.preferredLanguage.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var preferredRegion: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.preferredRegion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.preferredRegion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var crashReport: NotificareEvent? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.crashReport.rawValue) else {
                return nil
            }

            do {
                return try NotificareUtils.jsonDecoder.decode(NotificareEvent.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored crash report.\n\(error)")
                
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
                NotificareLogger.warning("Failed to encode the stored crash report.\n\(error)")
            }
        }
    }
    
    static var currentDatabaseVersion: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.currentDatabaseVersion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.currentDatabaseVersion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
