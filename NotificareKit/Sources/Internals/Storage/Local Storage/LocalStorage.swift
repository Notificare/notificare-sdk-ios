//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

enum LocalStorage {
    private enum Keys: String {
        case currentDatabaseVersion = "re.notifica.local_storage.current_database_version"
        case preferredLanguage = "re.notifica.local_storage.preferred_language"
        case preferredRegion = "re.notifica.local_storage.preferred_region"
        case registeredDevice = "re.notifica.local_storage.registered_device"
        case crashReport = "re.notifica.local_storage.crash_report"
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

    static var registeredDevice: NotificareDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: Keys.registeredDevice.rawValue) as? Data else {
                return nil
            }

            let decoder = NotificareUtils.jsonDecoder
            return try? decoder.decode(NotificareDevice.self, from: data)
        }
        set {
            let settings = UserDefaults.standard
            guard let newValue = newValue else {
                settings.removeObject(forKey: Keys.registeredDevice.rawValue)
                return
            }

            let encoder = NotificareUtils.jsonEncoder
            guard let data = try? encoder.encode(newValue) else {
                return
            }

            settings.set(data, forKey: Keys.registeredDevice.rawValue)
            settings.synchronize()
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

            return try? NotificareUtils.jsonDecoder.decode(NotificareEvent.self, from: data)
        }
        set {
            guard let event = newValue else {
                UserDefaults.standard.removeObject(forKey: Keys.crashReport.rawValue)
                return
            }

            guard let data = try? NotificareUtils.jsonEncoder.encode(event) else {
                return
            }

            UserDefaults.standard.set(data, forKey: Keys.crashReport.rawValue)
        }
    }
}
