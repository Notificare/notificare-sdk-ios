//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

public class NotificareDeviceManager {
    public private(set) var currentDevice: NotificareDevice? {
        get {
            LocalStorage.device
        }
        set {
            LocalStorage.device = newValue
        }
    }

    public var preferredLanguage: String? {
        guard let preferredLanguage = LocalStorage.preferredLanguage,
              let preferredRegion = LocalStorage.preferredRegion
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

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        if let device = currentDevice {
            if device.appVersion != NotificareUtils.applicationVersion {
                // It's not the same version, let's log it as an upgrade.
                NotificareLogger.debug("New version detected")
                Notificare.shared.eventsManager.logApplicationUpgrade()
            }

            register(transport: device.transport, token: device.id, userId: device.userId, userName: device.userName) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    NotificareLogger.warning("Failed to register device: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            NotificareLogger.debug("New install detected")

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
                    NotificareLogger.warning("Failed to register temporary device: \(error)")
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
            completion(.failure(NotificareError.notReady))
            return
        }

        register(transport: device.transport, token: device.id, userId: userId, userName: userName, completion)
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<String?>) {
        guard Notificare.shared.isReady else {
            completion(.failure(NotificareError.notReady))
            return
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

            // TODO: improve language validator
            guard parts.count == 2 else {
                NotificareLogger.error("Not a valid preferred language. Use a ISO 639-1 language code and a ISO 3166-2 region code (e.g. en-US).")
                completion(.failure(NotificareError.invalidLanguageCode))
                return
            }

            let language = parts[0]
            let region = parts[1]

            // Only update if the value is not the same.
            guard language != LocalStorage.preferredLanguage, region != LocalStorage.preferredRegion else {
                completion(.success("\(language)-\(region)"))
                return
            }

            LocalStorage.preferredLanguage = language
            LocalStorage.preferredRegion = region

            updateLanguage { result in
                switch result {
                case .success:
                    completion(.success("\(language)-\(region)"))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            LocalStorage.preferredLanguage = nil
            LocalStorage.preferredRegion = nil

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
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .get("/device/\(device.id)/tags")
            .responseDecodable(PushAPI.Responses.Tags.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.tags))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        addTags([tag], completion)
    }

    public func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/addtags", body: PushAPI.Payloads.Device.Tags(tags: tags))
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        removeTags([tag], completion)
    }

    public func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/removetags", body: PushAPI.Payloads.Device.Tags(tags: tags))
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func clearTags(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/cleartags")
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .get("/device/\(device.id)/dnd")
            .responseDecodable(PushAPI.Responses.DoNotDisturb.self) { result in
                switch result {
                case let .success(response):
                    // Update current device properties.
                    self.currentDevice?.dnd = response.dnd

                    completion(.success(response.dnd))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/dnd", body: dnd)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.dnd = dnd

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/cleardnd")
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.dnd = nil

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData?>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .get("/device/\(device.id)/userdata")
            .responseDecodable(PushAPI.Responses.UserData.self) { result in
                switch result {
                case let .success(response):
                    // Update current device properties.
                    self.currentDevice?.userData = response.userData

                    completion(.success(response.userData))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/userdata", body: userData)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.userData = userData

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    internal func delete(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .delete("/device/\(device.id)")
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice = nil

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Internal API

    public func updateNotificationSettings(_ allowedUI: Bool, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = PushAPI.Payloads.Device.UpdateNotificationSettings(
            language: getLanguage(),
            region: getRegion(),
            allowedUI: allowedUI
        )

        NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.allowedUI = allowedUI

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    func updateTimezone(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = PushAPI.Payloads.Device.UpdateTimeZone(
            language: getLanguage(),
            region: getRegion(),
            timeZoneOffset: NotificareUtils.timeZoneOffset
        )

        NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.timeZoneOffset = payload.timeZoneOffset

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    func updateLanguage(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = PushAPI.Payloads.Device.UpdateLanguage(
            language: getLanguage(),
            region: getRegion()
        )

        NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.language = payload.language
                    self.currentDevice?.region = payload.region

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    func updateBackgroundAppRefresh(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = PushAPI.Payloads.Device.UpdateBackgroundAppRefresh(
            language: getLanguage(),
            region: getRegion(),
            backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available
        )

        NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response { result in
                switch result {
                case .success:
                    // Update current device properties.
                    self.currentDevice?.backgroundAppRefresh = payload.backgroundAppRefresh

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

            let deviceRegistration = PushAPI.Payloads.Device.Registration(
                deviceID: token,
                oldDeviceId: oldDeviceId,
                userID: userId,
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

            NotificareRequest.Builder()
                .post("/device", body: deviceRegistration)
                .response { result in
                    switch result {
                    case .success:
                        let device = NotificareDevice(from: deviceRegistration, previous: self.currentDevice)

                        // Update and store the cached device.
                        self.currentDevice = device

                        // Notify delegate.
                        Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)

                        completion(.success(()))
                    case let .failure(error):
                        NotificareLogger.error("Failed to register device: \(error)")
                        completion(.failure(error))
                    }
                }
        } else {
            NotificareLogger.info("Skipping device registration, nothing changed.")
            Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: currentDevice!)
            completion(.success(()))
        }
    }

    public func registerTemporary(_ completion: @escaping NotificareCallback<Void>) {
        var token = withUnsafePointer(to: UUID().uuid) {
            Data(bytes: $0, count: 16)
        }.toHexString()

        // NOTE: keep the same token if available and only when not changing transport providers.
        if let device = currentDevice, device.transport == .notificare {
            token = device.id
        }

        register(
            transport: .notificare,
            token: token,
            userId: currentDevice?.userId,
            userName: currentDevice?.userName,
            completion
        )
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
            NotificareLogger.debug("Registration check: fresh installation")
            return true
        }

        var changed = false

        if userId != device.userId {
            NotificareLogger.debug("Registration check: user id changed")
            changed = true
        }

        if userName != device.userName {
            NotificareLogger.debug("Registration check: user name changed")
            changed = true
        }

        if device.id != token {
            NotificareLogger.debug("Registration check: device token changed")
            changed = true
        }

        if device.deviceString != NotificareUtils.deviceString {
            NotificareLogger.debug("Registration check: device string changed")
            changed = true
        }

        if device.appVersion != NotificareUtils.applicationVersion {
            NotificareLogger.debug("Registration check: application version changed")
            changed = true
        }

        if device.osVersion != NotificareUtils.osVersion {
            NotificareLogger.debug("Registration check: OS version changed")
            changed = true
        }

        let oneDayAgo = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date())!

        if device.lastRegistered.compare(oneDayAgo) == .orderedAscending {
            NotificareLogger.debug("Registration check: device registered more than a day ago")
            changed = true
        }

        if device.sdkVersion != NotificareDefinitions.sdkVersion {
            NotificareLogger.debug("Registration check: sdk version changed")
            changed = true
        }

        if device.timeZoneOffset != NotificareUtils.timeZoneOffset {
            NotificareLogger.debug("Registration check: timezone offset changed")
            changed = true
        }

        if device.language != getLanguage() {
            NotificareLogger.debug("Registration check: language changed")
            changed = true
        }

        if device.region != getRegion() {
            NotificareLogger.debug("Registration check: region changed")
            changed = true
        }

        return changed
    }

    private func getLanguage() -> String {
        LocalStorage.preferredLanguage ?? NotificareUtils.deviceLanguage
    }

    private func getRegion() -> String {
        LocalStorage.preferredRegion ?? NotificareUtils.deviceRegion
    }

    // MARK: - Notification Center listeners

    @objc private func updateDeviceTimezone() {
        NotificareLogger.info("Device timezone changed.")

        updateTimezone { result in
            if case .success = result {
                NotificareLogger.info("Device timezone updated.")
            }
        }
    }

    @objc private func updateDeviceLanguage() {
        NotificareLogger.info("Device language changed.")

        updateLanguage { result in
            if case .success = result {
                NotificareLogger.info("Device language updated.")
            }
        }
    }

    @objc private func updateDeviceBackgroundAppRefresh() {
        NotificareLogger.info("Device background app refresh status changed.")

        updateBackgroundAppRefresh { result in
            if case .success = result {
                NotificareLogger.info("Device background app refresh status updated.")
            }
        }
    }
}
