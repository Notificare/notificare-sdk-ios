//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareUserDefaults {
    static var currentDatabaseVersion: String? {
        get {
            UserDefaults.standard.string(forKey: NotificareDefinitions.UserDefaults.currentDatabaseVersion)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareDefinitions.UserDefaults.currentDatabaseVersion)
            UserDefaults.standard.synchronize()
        }
    }

    static var registeredDevice: NotificareDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: NotificareDefinitions.UserDefaults.registeredDevice) as? Data else {
                return nil
            }

            let decoder = NotificareUtils.createJsonDecoder()
            return try? decoder.decode(NotificareDevice.self, from: data)
        }
        set {
            let settings = UserDefaults.standard
            guard let newValue = newValue else {
                settings.removeObject(forKey: NotificareDefinitions.UserDefaults.registeredDevice)
                return
            }

            let encoder = NotificareUtils.createJsonEncoder()
            guard let data = try? encoder.encode(newValue) else {
                return
            }

            settings.set(data, forKey: NotificareDefinitions.UserDefaults.registeredDevice)
            settings.synchronize()
        }
    }

    static var preferredLanguage: String? {
        get {
            UserDefaults.standard.string(forKey: NotificareDefinitions.UserDefaults.preferredLanguage)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareDefinitions.UserDefaults.preferredLanguage)
            UserDefaults.standard.synchronize()
        }
    }

    static var preferredRegion: String? {
        get {
            UserDefaults.standard.string(forKey: NotificareDefinitions.UserDefaults.preferredRegion)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareDefinitions.UserDefaults.preferredRegion)
            UserDefaults.standard.synchronize()
        }
    }

    static var crashReport: NotificareEvent? {
        get {
            guard let data = UserDefaults.standard.data(forKey: NotificareDefinitions.UserDefaults.crashReport) else {
                return nil
            }

            let decoder = NotificareUtils.createJsonDecoder()
            return try? decoder.decode(NotificareEvent.self, from: data)
        }
        set {
            guard let event = newValue else {
                UserDefaults.standard.removeObject(forKey: NotificareDefinitions.UserDefaults.crashReport)
                return
            }

            let encoder = NotificareUtils.createJsonEncoder()
            guard let data = try? encoder.encode(event) else {
                return
            }

            UserDefaults.standard.set(data, forKey: NotificareDefinitions.UserDefaults.crashReport)
        }
    }
}
