//
// Created by Helder Pinhal on 04/08/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public class NotificareDeviceManager {

    public static let shared = NotificareDeviceManager()

    private(set) var sessionId: String?
    private(set) var device: NotificareDevice?


    private init() {}


    func configure() {
        self.sessionId = UUID().uuidString

        // TODO handle migration


        // Load the registered device.
        self.device = NotificareLocalStorage.registeredDevice
    }

    func launch(_ completion: @escaping (Result<Void, NotificareError>) -> Void) {
        if let device = NotificareDeviceManager.shared.device {
            if device.appVersion != NotificareUtils.applicationVersion {
                // It's not the same version, let's log it as an upgrade.
                Notificare.shared.logger.debug("New version detected")

                // TODO log app upgrade event
                // Log an application upgrade event.

                completion(.success(()))
            } else {
                // Nothing new.
                completion(.success(()))
            }
        } else {
            Notificare.shared.logger.debug("New install detected")

            //Let's avoid the new registration event for a temporary device
            NotificareLocalStorage.newRegistration = false

            //Let's logout the user in case there's an account in the keychain
            // TODO [[NotificareAuth shared] logoutAccount]

            NotificareDeviceManager.shared.registerTemporary { result in
                switch result {
                case .success(_):
                    // TODO log app install event
                    // We will log the Install here since this will execute only one time at the start.

                    // TODO log app open event
                    // We will log the App Open this first time here.

                    completion(.success(()))
                case .failure(let error):
                    Notificare.shared.logger.warning("Failed to register temporary device: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    func register(deviceToken: Data, asTemporary temporary: Bool = false, withUserId userId: String? = nil, andUserName userName: String? = nil, _ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        guard let pushApi = Notificare.shared.pushApi else {
            completion(.failure(.notConfigured))
            return
        }

        let token = deviceToken.toHexString()

        if registrationChanged(token: token, userId: userId, userName: userName) {
            let oldDeviceId = self.device?.deviceID != nil && self.device?.deviceID != token ? self.device?.deviceID : nil

            let deviceRegistration = NotificareDeviceRegistration(
                    deviceId: token,
                    oldDeviceId: oldDeviceId,
                    userId: userId,
                    userName: userName,
                    country: self.device?.countryCode,
                    language: NotificareUtils.deviceLanguage,
                    region: NotificareUtils.deviceRegion,
                    platform: "iOS",
                    transport: temporary ? .notificare : .apns,
                    osVersion: NotificareUtils.osVersion,
                    sdkVersion: NotificareConstants.sdkVersion,
                    appVersion: NotificareUtils.applicationVersion,
                    deviceString: NotificareUtils.deviceString,
                    timeZoneOffset: NotificareUtils.timeZoneOffset,
                    backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available
            )

            pushApi.createDevice(with: deviceRegistration) { result in
                switch result {
                case .success:
                    self.refreshCachedDevice(deviceRegistration.toStoredDevice(with: deviceToken)) { result in
                        switch result {
                        case .success(let device):
                            // Notify delegate.
                            Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)

                            // TODO handle new registration & event logging

                            completion(.success(device))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
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

    func registerTemporary(_ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        let uuid = UUID().uuidString
        let uuidData = uuid.data(using: .utf8)!

        self.register(deviceToken: uuidData, asTemporary: true, withUserId: self.device?.userID, andUserName: self.device?.userName) { result in
            switch result {
            case .success:
                self.updateNotificationSettings(allowedUI: false, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func delete(_ completion: @escaping (Result<Void, NotificareError>) -> Void) {

    }

    func updateNotificationSettings(allowedUI: Bool, _ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        guard var device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let payload = NotificareDeviceUpdateNotificationSettings(
                language: self.getLanguage(),
                region: self.getRegion(),
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
                device.allowedUI = allowedUI

                self.refreshCachedDevice(device, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

//    // TODO update location type
//    func updateLocation(location: Any, _ completion: @escaping (Result<Void, NotificareError>) -> Void) {
//        guard var device = self.device else {
//            completion(.failure(.noDevice))
//            return
//        }
//
//        let payload = NotificareDeviceUpdateNotificationSettings(
//                language: self.getLanguage(),
//                region: self.getRegion(),
//                allowedUI: allowedUI
//        )
//
//        guard let pushApi = Notificare.shared.pushApi else {
//            completion(.failure(.notConfigured))
//            return
//        }
//
//        pushApi.updateDevice(device.deviceID, with: payload) { result in
//            switch result {
//            case .success:
//                // update stored device
//                completion(.success(()))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }

    func clearLocation(_ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        guard var device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let payload = NotificareDeviceUpdateLocation(
                language: self.getLanguage(),
                region: self.getRegion(),
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
                device.latitude = nil
                device.longitude = nil
                device.altitude = nil
                device.accuracy = nil
                device.speed = nil
                device.course = nil
                device.floor = nil
                device.country = nil
                device.countryCode = nil
                device.allowedLocationServices = false

                self.refreshCachedDevice(device, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateTimezone(_ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        guard var device = self.device else {
            completion(.failure(.noDevice))
            return
        }

        let timeZoneOffset = NotificareUtils.timeZoneOffset

        let payload = NotificareDeviceUpdateTimezone(
                language: self.getLanguage(),
                region: self.getRegion(),
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
                device.timezone = timeZoneOffset

                self.refreshCachedDevice(device, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateLanguage(_ completion: @escaping (Result<Void, NotificareError>) -> Void) {

    }

    func updateBackgroundAppRefresh(_ completion: @escaping (Result<Void, NotificareError>) -> Void) {

    }

    func updateBluetoothState(bluetoothEnabled: Bool, _ completion: @escaping (Result<Void, NotificareError>) -> Void) {

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

//        if device.model != NotificareUtils.deviceString {
//            Notificare.shared.logger.debug("Registration check: device model changed")
//            changed = true
//        }

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

        if device.sdkVersion != NotificareConstants.sdkVersion {
            Notificare.shared.logger.debug("Registration check: sdk version changed")
            changed = true
        }

        if device.timezone != NotificareUtils.timeZoneOffset {
            Notificare.shared.logger.debug("Registration check: timezone offset changed")
            changed = true
        }

        let language = UserDefaults.standard.string(forKey: NotificareConstants.UserDefaults.preferredLanguage) ?? NotificareUtils.deviceLanguage
        let region = UserDefaults.standard.string(forKey: NotificareConstants.UserDefaults.preferredRegion) ?? NotificareUtils.deviceRegion

        if device.language != language {
            Notificare.shared.logger.debug("Registration check: language changed")
            changed = true
        }

        if device.region != region {
            Notificare.shared.logger.debug("Registration check: region changed")
            changed = true
        }

        return changed
    }

    private func getLanguage() -> String {
        NotificareLocalStorage.preferredLanguage ?? NotificareUtils.deviceLanguage
    }

    private func getRegion() -> String {
        NotificareLocalStorage.preferredRegion ?? NotificareUtils.deviceRegion
    }

    private func refreshCachedDevice(_ updatedDevice: NotificareDevice, _ completion: @escaping (Result<NotificareDevice, NotificareError>) -> Void) {
        // Persist updated device to storage.
        NotificareLocalStorage.registeredDevice = updatedDevice

        if let device = NotificareLocalStorage.registeredDevice {
            // Update the cached device.
            self.device = device

            // Bubble up the device.
            completion(.success(device))
        } else {
            // Should not happen, unless we concurrently remove the device from storage.
            completion(.failure(.noDevice))
        }
    }
}
