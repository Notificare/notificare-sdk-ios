//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public class NotificareDeviceManager {
    public private(set) var currentDevice: NotificareDevice? {
        get {
            NotificareUserDefaults.registeredDevice
        }
        set {
            NotificareUserDefaults.registeredDevice = newValue
        }
    }

    public var preferredLanguage: String? {
        guard let preferredLanguage = NotificareUserDefaults.preferredLanguage,
              let preferredRegion = NotificareUserDefaults.preferredRegion
        else {
            return nil
        }

        return "\(preferredLanguage)-\(preferredRegion)"
    }

    func configure() {
        // TODO: handle migration

        // Listen to timezone changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDeviceTimezone),
                                               name: UIApplication.significantTimeChangeNotification,
                                               object: nil)

        // Listen to language changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDeviceLanguage),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)

        // Listen to 'background refresh status' changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDeviceBackgroundAppRefresh),
                                               name: UIApplication.backgroundRefreshStatusDidChangeNotification,
                                               object: nil)
    }

    func launch(_ completion: @escaping (Result<Void, NotificareError>) -> Void) {
        if let device = currentDevice {
            if device.appVersion != NotificareUtils.applicationVersion {
                // It's not the same version, let's log it as an upgrade.
                Notificare.shared.logger.debug("New version detected")
                Notificare.shared.eventsManager.logApplicationUpgrade()
            }

            register(transport: device.transport, token: device.id, userId: device.userId, userName: device.userName) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    Notificare.shared.logger.warning("Failed to register device: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            Notificare.shared.logger.debug("New install detected")

            // Let's logout the user in case there's an account in the keychain
            // TODO: [[NotificareAuth shared] logoutAccount]

            registerTemporary { result in
                switch result {
                case .success:
                    // We will log the Install & Registration events here since this will execute only one time at the start.
                    Notificare.shared.eventsManager.logApplicationInstall()
                    Notificare.shared.eventsManager.logApplicationRegistration()

                    completion(.success(()))
                case let .failure(error):
                    Notificare.shared.logger.warning("Failed to register temporary device: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Public API

    public func register(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice
        else {
            completion(.failure(.notReady))
            return
        }

        register(transport: device.transport, token: device.id, userId: userId, userName: userName, completion)
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<String?>) {
        guard Notificare.shared.isReady else {
            completion(.failure(.notReady))
            return
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

            // TODO: improve language validator
            guard parts.count == 2 else {
                Notificare.shared.logger.error("Not a valid preferred language. Use a ISO 639-1 language code and a ISO 3166-2 region code (e.g. en-US).")
                completion(.failure(.invalidLanguageCode))
                return
            }

            let language = parts[0]
            let region = parts[1]

            // Only update if the value is not the same.
            guard language != NotificareUserDefaults.preferredLanguage, region != NotificareUserDefaults.preferredRegion else {
                completion(.success("\(language)-\(region)"))
                return
            }

            NotificareUserDefaults.preferredLanguage = language
            NotificareUserDefaults.preferredRegion = region

            updateLanguage { result in
                switch result {
                case .success:
                    completion(.success("\(language)-\(region)"))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            NotificareUserDefaults.preferredLanguage = nil
            NotificareUserDefaults.preferredRegion = nil

            updateLanguage { result in
                switch result {
                case .success:
                    completion(.success(nil))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func fetchTags(_ completion: @escaping NotificareCallback<[String]>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.getDeviceTags(with: device.id, completion)
    }

    public func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        addTags([tag], completion)
    }

    public func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let payload = NotificareTagsPayload(tags: tags)

        pushApi.addDeviceTags(with: device.id, payload: payload, completion)
    }

    public func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        removeTags([tag], completion)
    }

    public func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let payload = NotificareTagsPayload(tags: tags)

        pushApi.removeDeviceTags(with: device.id, payload: payload, completion)
    }

    public func clearTags(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.clearDeviceTags(with: device.id, completion)
    }

    public func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.fetchDeviceDoNotDisturb(device.id) { result in
            switch result {
            case let .success(dnd):
                // Update current device properties.
                self.currentDevice!.dnd = dnd

                completion(.success(dnd))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.updateDeviceDoNotDisturb(device.id, dnd: dnd) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.dnd = dnd

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.clearDeviceDoNotDisturb(device.id) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.dnd = nil

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData?>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.fetchDeviceUserData(device.id) { result in
            switch result {
            case let .success(userData):
                // Update current device properties.
                self.currentDevice!.userData = userData

                completion(.success(userData))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        pushApi.updateDeviceUserData(device.id, userData: userData) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.userData = userData

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Internal API

    public func updateNotificationSettings(_ allowedUI: Bool, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let payload = NotificareDeviceUpdateNotificationSettings(
            language: getLanguage(),
            region: getRegion(),
            allowedUI: allowedUI
        )

        pushApi.updateDevice(device.id, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.allowedUI = payload.allowedUI

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateTimezone(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let timeZoneOffset = NotificareUtils.timeZoneOffset

        let payload = NotificareDeviceUpdateTimezone(
            language: getLanguage(),
            region: getRegion(),
            timeZoneOffset: timeZoneOffset
        )

        pushApi.updateDevice(device.id, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.timeZoneOffset = timeZoneOffset

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateLanguage(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let payload = NotificareDeviceUpdateLanguage(
            language: getLanguage(),
            region: getRegion()
        )

        pushApi.updateDevice(device.id, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.language = payload.language
                self.currentDevice!.region = payload.region

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateBackgroundAppRefresh(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice,
              let pushApi = Notificare.shared.pushApi
        else {
            completion(.failure(.notReady))
            return
        }

        let backgroundAppRefresh = UIApplication.shared.backgroundRefreshStatus == .available

        let payload = NotificareDeviceUpdateBackgroundAppRefresh(
            language: getLanguage(),
            region: getRegion(),
            backgroundAppRefresh: backgroundAppRefresh
        )

        pushApi.updateDevice(device.id, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.currentDevice!.backgroundAppRefresh = payload.backgroundAppRefresh

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // func updateBluetoothState(bluetoothEnabled _: Bool, _: @escaping DeviceCallback) {}

    // MARK: - Private API

    private func register(transport: NotificareTransport, token: String, userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>) {
        if registrationChanged(token: token, userId: userId, userName: userName) {
            let oldDeviceId = currentDevice?.id != nil && currentDevice?.id != token ? currentDevice?.id : nil

            let deviceRegistration = NotificareDeviceRegistration(
                deviceId: token,
                oldDeviceId: oldDeviceId,
                userId: userId,
                userName: userName,
                language: getLanguage(),
                region: getRegion(),
                platform: "iOS",
                transport: transport,
                osVersion: NotificareUtils.osVersion,
                sdkVersion: NotificareDefinitions.sdkVersion,
                appVersion: NotificareUtils.applicationVersion,
                deviceString: NotificareUtils.deviceString,
                timeZoneOffset: NotificareUtils.timeZoneOffset,
                allowedUI: transport == .notificare ? false : currentDevice?.allowedUI ?? false,
                backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available
            )

            Notificare.shared.pushApi!.createDevice(with: deviceRegistration) { result in
                switch result {
                case .success:
                    let device = NotificareDevice(from: deviceRegistration, previous: self.currentDevice)

                    // Update and store the cached device.
                    self.currentDevice = device

                    // Notify delegate.
                    Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)

                    completion(.success(()))
                case let .failure(error):
                    Notificare.shared.logger.error("Failed to register device: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            Notificare.shared.logger.info("Skipping device registration, nothing changed.")
            Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: currentDevice!)
            completion(.success(()))
        }
    }

    private func registerTemporary(_ completion: @escaping NotificareCallback<Void>) {
        let token = currentDevice?.id ?? withUnsafePointer(to: UUID().uuid) {
            Data(bytes: $0, count: 16)
        }.toHexString()

        register(
            transport: .notificare,
            token: token,
            userId: currentDevice?.userId,
            userName: currentDevice?.userName,
            completion
        )
//        { result in
//            switch result {
//            case .success:
//                self.updateNotificationSettings(allowedUI: false, completion)
//            case let .failure(error):
//                completion(.failure(error))
//            }
//        }
    }

    public func registerAPNS(token: String, _ completion: @escaping NotificareCallback<Void>) {
        register(
            transport: .apns,
            token: token,
            userId: currentDevice?.userId,
            userName: currentDevice?.userName,
            completion
        )
    }

    private func registrationChanged(token: String, userId: String?, userName: String?) -> Bool {
        guard let device = currentDevice else {
            Notificare.shared.logger.debug("Registration check: fresh installation")
            return true
        }

        var changed = false

        if userId != device.userId {
            Notificare.shared.logger.debug("Registration check: user id changed")
            changed = true
        }

        if userName != device.userName {
            Notificare.shared.logger.debug("Registration check: user name changed")
            changed = true
        }

        if device.id != token {
            Notificare.shared.logger.debug("Registration check: device token changed")
            changed = true
        }

        if device.deviceString != NotificareUtils.deviceString {
            Notificare.shared.logger.debug("Registration check: device string changed")
            changed = true
        }

        if device.appVersion != NotificareUtils.applicationVersion {
            Notificare.shared.logger.debug("Registration check: application version changed")
            changed = true
        }

        if device.osVersion != NotificareUtils.osVersion {
            Notificare.shared.logger.debug("Registration check: OS version changed")
            changed = true
        }

        let oneDayAgo = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date())!

        if device.lastRegistered.compare(oneDayAgo) == .orderedAscending {
            Notificare.shared.logger.debug("Registration check: device registered more than a day ago")
            changed = true
        }

        if device.sdkVersion != NotificareDefinitions.sdkVersion {
            Notificare.shared.logger.debug("Registration check: sdk version changed")
            changed = true
        }

        if device.timeZoneOffset != NotificareUtils.timeZoneOffset {
            Notificare.shared.logger.debug("Registration check: timezone offset changed")
            changed = true
        }

        if device.language != getLanguage() {
            Notificare.shared.logger.debug("Registration check: language changed")
            changed = true
        }

        if device.region != getRegion() {
            Notificare.shared.logger.debug("Registration check: region changed")
            changed = true
        }

        return changed
    }

    private func getLanguage() -> String {
        NotificareUserDefaults.preferredLanguage ?? NotificareUtils.deviceLanguage
    }

    private func getRegion() -> String {
        NotificareUserDefaults.preferredRegion ?? NotificareUtils.deviceRegion
    }

    // MARK: - Notification Center listeners

    @objc private func updateDeviceTimezone() {
        Notificare.shared.logger.info("Device timezone changed.")

        updateTimezone { result in
            if case .success = result {
                Notificare.shared.logger.info("Device timezone updated.")
            }
        }
    }

    @objc private func updateDeviceLanguage() {
        Notificare.shared.logger.info("Device language changed.")

        updateLanguage { result in
            if case .success = result {
                Notificare.shared.logger.info("Device language updated.")
            }
        }
    }

    @objc private func updateDeviceBackgroundAppRefresh() {
        Notificare.shared.logger.info("Device background app refresh status changed.")

        updateBackgroundAppRefresh { result in
            if case .success = result {
                Notificare.shared.logger.info("Device background app refresh status updated.")
            }
        }
    }
}