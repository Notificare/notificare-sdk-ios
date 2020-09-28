//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareLocalStorage {
    static var registeredDevice: NotificareDevice? {
        get {
            let settings = UserDefaults.standard
            guard let data = settings.object(forKey: NotificareConstants.UserDefaults.registeredDevice) as? Data else {
                return nil
            }

            let decoder = NotificareUtils.createJsonDecoder()
            return try? decoder.decode(NotificareDevice.self, from: data)
        }
        set {
            let settings = UserDefaults.standard
            guard let newValue = newValue else {
                settings.removeObject(forKey: NotificareConstants.UserDefaults.registeredDevice)
                return
            }

            let encoder = NotificareUtils.createJsonEncoder()
            guard let data = try? encoder.encode(newValue) else {
                return
            }

            settings.set(data, forKey: NotificareConstants.UserDefaults.registeredDevice)
            settings.synchronize()
        }
    }

    static var preferredLanguage: String? {
        get {
            UserDefaults.standard.string(forKey: NotificareConstants.UserDefaults.preferredLanguage)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareConstants.UserDefaults.preferredLanguage)
            UserDefaults.standard.synchronize()
        }
    }

    static var preferredRegion: String? {
        get {
            UserDefaults.standard.string(forKey: NotificareConstants.UserDefaults.preferredRegion)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareConstants.UserDefaults.preferredRegion)
            UserDefaults.standard.synchronize()
        }
    }

    static var newRegistration: Bool {
        get {
            UserDefaults.standard.bool(forKey: NotificareConstants.UserDefaults.newRegistration)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: NotificareConstants.UserDefaults.newRegistration)
            UserDefaults.standard.synchronize()
        }
    }

    private init() {}
}
