//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal enum LocalStorage {
    private enum Keys: String {
        case remoteNotificationsEnabled = "re.notifica.push.local_storage.remote_notifications_enabled"
        case transport = "re.notifica.push.local_storage.transport"
        case subscription = "re.notifica.push.local_storage.subscription"
        case allowedUI = "re.notifica.push.local_storage.allowed_ui"
        case firstRegistration = "re.notifica.push.local_storage.first_registration"
    }

    internal static var remoteNotificationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.remoteNotificationsEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.remoteNotificationsEnabled.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var transport: NotificareTransport? {
        get {
            guard let data = UserDefaults.standard.object(forKey: Keys.transport.rawValue) as? Data else {
                return nil
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode(NotificareTransport.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored transport.", error: error)

                // Remove the corrupted transport from local storage.
                UserDefaults.standard.removeObject(forKey: Keys.transport.rawValue)
                UserDefaults.standard.synchronize()

                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: Keys.transport.rawValue)
                return
            }

            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: Keys.transport.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the stored transport.", error: error)
            }
        }
    }

    internal static var subscription: NotificarePushSubscription? {
        get {
            guard let data = UserDefaults.standard.object(forKey: Keys.subscription.rawValue) as? Data else {
                return nil
            }

            do {
                let decoder = NotificareUtils.jsonDecoder
                return try decoder.decode(NotificarePushSubscription.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored subscription.", error: error)

                // Remove the corrupted value from local storage.
                UserDefaults.standard.removeObject(forKey: Keys.subscription.rawValue)
                UserDefaults.standard.synchronize()

                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                UserDefaults.standard.removeObject(forKey: Keys.subscription.rawValue)
                return
            }

            do {
                let encoder = NotificareUtils.jsonEncoder
                let data = try encoder.encode(newValue)

                UserDefaults.standard.set(data, forKey: Keys.subscription.rawValue)
                UserDefaults.standard.synchronize()
            } catch {
                NotificareLogger.warning("Failed to encode the stored subscription.", error: error)
            }
        }
    }

    internal static var allowedUI: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.allowedUI.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.allowedUI.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    internal static var firstRegistration: Bool {
        get {
            if UserDefaults.standard.value(forKey: Keys.firstRegistration.rawValue) == nil {
                return true
            }

            return UserDefaults.standard.bool(forKey: Keys.firstRegistration.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.firstRegistration.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}
