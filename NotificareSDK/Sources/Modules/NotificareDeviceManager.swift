//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public typealias DeviceCallback = (Result<NotificareDevice, NotificareError>) -> Void
public typealias PreferredLanguageCallback = (Result<String?, NotificareError>) -> Void

public class NotificareDeviceManager {
    public private(set) var device: NotificareDevice? {
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
        if let device = self.device {
            if device.appVersion != NotificareUtils.applicationVersion {
                // It's not the same version, let's log it as an upgrade.
                Notificare.shared.logger.debug("New version detected")

                // Log an application upgrade event.
                Notificare.shared.eventsManager.logApplicationUpgrade()

                completion(.success(()))
            } else {
                // Nothing new.
                completion(.success(()))
            }
        } else {
            Notificare.shared.logger.debug("New install detected")

            // Let's avoid the new registration event for a temporary device
            NotificareUserDefaults.newRegistration = false

            // Let's logout the user in case there's an account in the keychain
            // TODO: [[NotificareAuth shared] logoutAccount]

            registerTemporary { result in
                switch result {
                case .success:
                    // We will log the Install here since this will execute only one time at the start.
                    Notificare.shared.eventsManager.logApplicationInstall()

                    // We will log the App Open this first time here.
                    Notificare.shared.eventsManager.logApplicationOpen()

                    completion(.success(()))
                case let .failure(error):
                    Notificare.shared.logger.warning("Failed to register temporary device: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Public API

    public func register(userId: String?, userName: String?, _ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            Notificare.shared.logger.warning("No device has been registered. Cannot update user information.")
            completion(.failure(.noDevice))
            return
        }

        let tokenData = device.deviceTokenData
        let temporary = device.transport != .apns

        register(tokenData: tokenData, temporary: temporary, userId: userId, userName: userName, completion)
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping (Result<String?, NotificareError>) -> Void) {
        // TODO: improve readiness check to prevent the issue below

        guard let _ = device else {
            completion(.failure(.noDevice))
            return
        }

        guard let _ = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

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

    // MARK: - Internal API

    // func delete(_: @escaping (Result<Void, NotificareError>) -> Void) {}

    func updateNotificationSettings(allowedUI: Bool, _ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let payload = NotificareDeviceUpdateNotificationSettings(
            language: getLanguage(),
            region: getRegion(),
            allowedUI: allowedUI
        )

        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        pushApi.updateDevice(device.deviceID, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.device!.allowedUI = payload.allowedUI

                completion(.success(self.device!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // func updateLocation(location: NotificareLocation, _ completion: @escaping DeviceCallback) {}

    func clearLocation(_ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let payload = NotificareDeviceUpdateLocation(
            language: getLanguage(),
            region: getRegion(),
            latitude: nil,
            longitude: nil,
            altitude: nil,
            locationAccuracy: nil,
            speed: nil,
            course: nil,
            country: nil,
            floor: nil,
            locationServicesAuthStatus: nil,
            locationServicesAccuracyAuth: nil
        )

        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        pushApi.updateDevice(device.deviceID, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.device!.latitude = nil
                self.device!.longitude = nil
                self.device!.altitude = nil
                self.device!.accuracy = nil
                self.device!.speed = nil
                self.device!.course = nil
                self.device!.floor = nil
                self.device!.country = nil
                self.device!.countryCode = nil
                self.device!.allowedLocationServices = false

                completion(.success(self.device!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateTimezone(_ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let timeZoneOffset = NotificareUtils.timeZoneOffset

        let payload = NotificareDeviceUpdateTimezone(
            language: getLanguage(),
            region: getRegion(),
            timeZoneOffset: timeZoneOffset
        )

        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        pushApi.updateDevice(device.deviceID, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.device!.timezone = timeZoneOffset

                completion(.success(self.device!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateLanguage(_ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let payload = NotificareDeviceUpdateLanguage(
            language: getLanguage(),
            region: getRegion()
        )

        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        pushApi.updateDevice(device.deviceID, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.device!.language = payload.language
                self.device!.region = payload.region

                completion(.success(self.device!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func updateBackgroundAppRefresh(_ completion: @escaping DeviceCallback) {
        guard let device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let backgroundAppRefresh = UIApplication.shared.backgroundRefreshStatus == .available

        let payload = NotificareDeviceUpdateBackgroundAppRefresh(
            language: getLanguage(),
            region: getRegion(),
            backgroundAppRefresh: backgroundAppRefresh
        )

        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        pushApi.updateDevice(device.deviceID, with: payload) { result in
            switch result {
            case .success:
                // Update current device properties.
                self.device!.backgroundAppRefresh = payload.backgroundAppRefresh

                completion(.success(self.device!))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // func updateBluetoothState(bluetoothEnabled _: Bool, _: @escaping DeviceCallback) {}

    // MARK: - Private API

    private func register(tokenData: Data, temporary: Bool, userId: String?, userName: String?, _ completion: @escaping DeviceCallback) {
        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        let token = tokenData.toHexString()

        if registrationChanged(token: token, userId: userId, userName: userName) {
            let oldDeviceId = device?.deviceID != nil && device?.deviceID != token ? device?.deviceID : nil

            let deviceRegistration = NotificareDeviceRegistration(
                deviceId: token,
                oldDeviceId: oldDeviceId,
                userId: userId,
                userName: userName,
                country: device?.countryCode,
                language: getLanguage(),
                region: getRegion(),
                platform: "iOS",
                transport: temporary ? .notificare : .apns,
                osVersion: NotificareUtils.osVersion,
                sdkVersion: NotificareDefinitions.sdkVersion,
                appVersion: NotificareUtils.applicationVersion,
                deviceString: NotificareUtils.deviceString,
                timeZoneOffset: NotificareUtils.timeZoneOffset,
                backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available
            )

            pushApi.createDevice(with: deviceRegistration) { result in
                switch result {
                case .success:
                    let device = NotificareDevice(from: deviceRegistration, with: tokenData)

                    // Update and store the cached device.
                    self.device = device

                    // Notify delegate.
                    Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)

                    // If it's set to false let's log the first registration
                    if !NotificareUserDefaults.newRegistration {
                        Notificare.shared.eventsManager.logApplicationRegistration()
                        NotificareUserDefaults.newRegistration = true
                    }

                    completion(.success(device))
                case let .failure(error):
                    Notificare.shared.logger.error("Failed to register device: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            guard let device = self.device else {
                completion(.failure(.noDevice))
                return
            }

            Notificare.shared.logger.info("Skipping device registration, nothing changed.")
            Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)
            completion(.success(device))
        }
    }

    private func registerTemporary(_ completion: @escaping DeviceCallback) {
        let tokenData = withUnsafePointer(to: UUID().uuid) {
            Data(bytes: $0, count: 16)
        }

        register(
            tokenData: tokenData,
            temporary: true,
            userId: device?.userID,
            userName: device?.userName
        ) { result in
            switch result {
            case .success:
                self.updateNotificationSettings(allowedUI: false, completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func registrationChanged(token: String, userId: String?, userName: String?) -> Bool {
        guard let device = self.device else {
            Notificare.shared.logger.debug("Registration check: fresh installation")
            return true
        }

        var changed = false

        if userId != device.userID {
            Notificare.shared.logger.debug("Registration check: user id changed")
            changed = true
        }

        if userName != device.userName {
            Notificare.shared.logger.debug("Registration check: user name changed")
            changed = true
        }

        if device.deviceID != token {
            Notificare.shared.logger.debug("Registration check: device token changed")
            changed = true
        }

        if device.deviceModel != NotificareUtils.deviceString {
            Notificare.shared.logger.debug("Registration check: device model changed")
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

        if device.timezone != NotificareUtils.timeZoneOffset {
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
