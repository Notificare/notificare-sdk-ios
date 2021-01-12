//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareCore

extension NotificareUserDefaults {
    static var currentDatabaseVersion: String? {
        get {
            UserDefaults.standard.string(forKey: Key.currentDatabaseVersion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.currentDatabaseVersion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var registeredDevice: NotificareDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: Key.registeredDevice.rawValue) as? Data else {
                return nil
            }

            let decoder = NotificareUtils.jsonDecoder
            return try? decoder.decode(NotificareDevice.self, from: data)
        }
        set {
            let settings = UserDefaults.standard
            guard let newValue = newValue else {
                settings.removeObject(forKey: Key.registeredDevice.rawValue)
                return
            }

            let encoder = NotificareUtils.jsonEncoder
            guard let data = try? encoder.encode(newValue) else {
                return
            }

            settings.set(data, forKey: Key.registeredDevice.rawValue)
            settings.synchronize()
        }
    }

    static var preferredLanguage: String? {
        get {
            UserDefaults.standard.string(forKey: Key.preferredLanguage.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.preferredLanguage.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var preferredRegion: String? {
        get {
            UserDefaults.standard.string(forKey: Key.preferredRegion.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.preferredRegion.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var crashReport: NotificareEvent? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Key.crashReport.rawValue) else {
                return nil
            }

            return try? NotificareUtils.jsonDecoder.decode(NotificareEvent.self, from: data)
        }
        set {
            guard let event = newValue else {
                UserDefaults.standard.removeObject(forKey: Key.crashReport.rawValue)
                return
            }

            guard let data = try? NotificareUtils.jsonEncoder.encode(event) else {
                return
            }

            UserDefaults.standard.set(data, forKey: Key.crashReport.rawValue)
        }
    }
}
