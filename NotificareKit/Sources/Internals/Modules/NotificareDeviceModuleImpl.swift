//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

internal class NotificareDeviceModuleImpl: NSObject, NotificareModule, NotificareDeviceModule, NotificareInternalDeviceModule {
    // MARK: - Notificare Module

    static let instance = NotificareDeviceModuleImpl()

    func configure() {
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
            register(transport: device.transport, token: device.id, userId: device.userId, userName: device.userName) { result in
                switch result {
                case .success:
                    Notificare.shared.session().launch { result in
                        switch result {
                        case .success:
                            if device.appVersion != NotificareUtils.applicationVersion {
                                // It's not the same version, let's log it as an upgrade.
                                NotificareLogger.debug("New version detected")
                                Notificare.shared.eventsImplementation().logApplicationUpgrade { _ in }
                            }

                            completion(.success(()))

                        case let .failure(error):
                            NotificareLogger.debug("Failed to launch the session module.", error: error)
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    NotificareLogger.warning("Failed to register device.", error: error)
                    completion(.failure(error))
                }
            }
        } else {
            NotificareLogger.debug("New install detected")

            registerTemporary { result in
                switch result {
                case .success:
                    Notificare.shared.session().launch { result in
                        switch result {
                        case .success:
                            // We will log the Install & Registration events here since this will execute only one time at the start.
                            Notificare.shared.eventsImplementation().logApplicationInstall { _ in }
                            Notificare.shared.eventsImplementation().logApplicationRegistration { _ in }

                            completion(.success(()))

                        case let .failure(error):
                            NotificareLogger.debug("Failed to launch the session module.", error: error)
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    NotificareLogger.warning("Failed to register temporary device.", error: error)
                    completion(.failure(error))
                }
            }
        }
    }

    func postLaunch() async throws {
        if let device = currentDevice {
            DispatchQueue.main.async {
                Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)
            }
        }
    }

//    static func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
//
//    }

    // MARK: - Notificare Device Module

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

    public func register(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady,
              let device = currentDevice
        else {
            completion(.failure(NotificareError.notReady))
            return
        }

        register(transport: device.transport, token: device.id, userId: userId, userName: userName, completion)
    }

    @available(iOS 13.0, *)
    func register(userId: String?, userName: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            register(userId: userId, userName: userName) { result in
                continuation.resume(with: result)
            }
        }
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady else {
            completion(.failure(NotificareError.notReady))
            return
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

            // TODO: improve language validator
            guard parts.count == 2 else {
                NotificareLogger.error("Not a valid preferred language. Use a ISO 639-1 language code and a ISO 3166-2 region code (e.g. en-US).")
                completion(.failure(NotificareError.invalidArgument(message: "Invalid preferred language value '\(preferredLanguage)'.")))
                return
            }

            let language = parts[0]
            let region = parts[1]

            // Only update if the value is not the same.
            guard language != LocalStorage.preferredLanguage, region != LocalStorage.preferredRegion else {
                completion(.success(()))
                return
            }

            updateLanguage(language, region: region) { result in
                switch result {
                case .success:
                    LocalStorage.preferredLanguage = language
                    LocalStorage.preferredRegion = region

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            let language = NotificareUtils.deviceLanguage
            let region = NotificareUtils.deviceRegion

            updateLanguage(language, region: region) { result in
                switch result {
                case .success:
                    LocalStorage.preferredLanguage = nil
                    LocalStorage.preferredRegion = nil

                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    func updatePreferredLanguage(_ preferredLanguage: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            updatePreferredLanguage(preferredLanguage) { result in
                continuation.resume(with: result)
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
            .responseDecodable(NotificareInternals.PushAPI.Responses.Tags.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.tags))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchTags() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            fetchTags { result in
                continuation.resume(with: result)
            }
        }
    }

    public func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        addTags([tag], completion)
    }

    @available(iOS 13.0, *)
    func addTag(_ tag: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addTag(tag) { result in
                continuation.resume(with: result)
            }
        }
    }

    public func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/addtags", body: NotificareInternals.PushAPI.Payloads.Device.Tags(tags: tags))
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func addTags(_ tags: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addTags(tags) { result in
                continuation.resume(with: result)
            }
        }
    }

    public func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        removeTags([tag], completion)
    }

    @available(iOS 13.0, *)
    func removeTag(_ tag: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeTag(tag) { result in
                continuation.resume(with: result)
            }
        }
    }

    public func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .put("/device/\(device.id)/removetags", body: NotificareInternals.PushAPI.Payloads.Device.Tags(tags: tags))
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func removeTags(_ tags: [String]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeTags(tags) { result in
                continuation.resume(with: result)
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

    @available(iOS 13.0, *)
    func clearTags() async throws {
        try await withCheckedThrowingContinuation { continuation in
            clearTags { result in
                continuation.resume(with: result)
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
            .responseDecodable(NotificareInternals.PushAPI.Responses.DoNotDisturb.self) { result in
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

    @available(iOS 13.0, *)
    func fetchDoNotDisturb() async throws -> NotificareDoNotDisturb? {
        try await withCheckedThrowingContinuation { continuation in
            fetchDoNotDisturb { result in
                continuation.resume(with: result)
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

    @available(iOS 13.0, *)
    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb) async throws {
        try await withCheckedThrowingContinuation { continuation in
            updateDoNotDisturb(dnd) { result in
                continuation.resume(with: result)
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

    @available(iOS 13.0, *)
    func clearDoNotDisturb() async throws {
        try await withCheckedThrowingContinuation { continuation in
            clearDoNotDisturb { result in
                continuation.resume(with: result)
            }
        }
    }

    public func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        NotificareRequest.Builder()
            .get("/device/\(device.id)/userdata")
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserData.self) { result in
                switch result {
                case let .success(response):
                    let userData = response.userData?.compactMapValues { $0 } ?? [:]

                    // Update current device properties.
                    self.currentDevice?.userData = userData

                    completion(.success(userData))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchUserData() async throws -> NotificareUserData {
        try await withCheckedThrowingContinuation { continuation in
            fetchUserData { result in
                continuation.resume(with: result)
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

    @available(iOS 13.0, *)
    func updateUserData(_ userData: NotificareUserData) async throws {
        try await withCheckedThrowingContinuation { continuation in
            updateUserData(userData) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Notificare Internal Device Module

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

    // MARK: - Internal API

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

    internal func updateTimezone(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateTimeZone(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
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

    internal func updateLanguage(_ language: String, region: String, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateLanguage(
            language: language,
            region: region
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

    internal func updateBackgroundAppRefresh(_ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady, let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateBackgroundAppRefresh(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
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

    private func register(transport: NotificareTransport, token: String, userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>) {
        if registrationChanged(token: token, userId: userId, userName: userName) {
            // NOTE: the backgroundRefreshStatus will print a warning when accessed from background threads.
            DispatchQueue.main.async {
                let oldDeviceId = self.currentDevice?.id != nil && self.currentDevice?.id != token ? self.currentDevice?.id : nil

                let deviceRegistration = NotificareInternals.PushAPI.Payloads.Device.Registration(
                    deviceID: token,
                    oldDeviceID: oldDeviceId,
                    userID: userId,
                    userName: userName,
                    language: self.getDeviceLanguage(),
                    region: self.getDeviceRegion(),
                    platform: "iOS",
                    transport: transport,
                    osVersion: NotificareUtils.osVersion,
                    sdkVersion: Notificare.SDK_VERSION,
                    appVersion: NotificareUtils.applicationVersion,
                    deviceString: NotificareUtils.deviceString,
                    timeZoneOffset: NotificareUtils.timeZoneOffset,
                    backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available,

                    // Submit a value when registering a temporary to prevent
                    // otherwise let the push module take over and update the setting accordingly.
                    allowedUI: transport == .notificare ? false : nil
                )

                NotificareRequest.Builder()
                    .post("/device", body: deviceRegistration)
                    .response { result in
                        switch result {
                        case .success:
                            let device = NotificareDevice(from: deviceRegistration, previous: self.currentDevice)

                            // Update and store the cached device.
                            self.currentDevice = device

                            if Notificare.shared.isReady {
                                DispatchQueue.main.async {
                                    // Notify delegate.
                                    Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)
                                }
                            }

                            completion(.success(()))
                        case let .failure(error):
                            NotificareLogger.error("Failed to register device.", error: error)
                            completion(.failure(error))
                        }
                    }
            }
        } else {
            NotificareLogger.info("Skipping device registration, nothing changed.")

            if Notificare.shared.isReady {
                DispatchQueue.main.async {
                    Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: self.currentDevice!)
                }
            }

            completion(.success(()))
        }
    }

    internal func registerTestDevice(nonce: String, _ completion: @escaping NotificareCallback<Void>) {
        guard let device = currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.TestDeviceRegistration(
            deviceID: device.id
        )

        NotificareRequest.Builder()
            .put("/support/testdevice/\(nonce)", body: payload)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
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

        if device.sdkVersion != Notificare.SDK_VERSION {
            NotificareLogger.debug("Registration check: sdk version changed")
            changed = true
        }

        if device.timeZoneOffset != NotificareUtils.timeZoneOffset {
            NotificareLogger.debug("Registration check: timezone offset changed")
            changed = true
        }

        if device.language != getDeviceLanguage() {
            NotificareLogger.debug("Registration check: language changed")
            changed = true
        }

        if device.region != getDeviceRegion() {
            NotificareLogger.debug("Registration check: region changed")
            changed = true
        }

        return changed
    }

    private func getDeviceLanguage() -> String {
        LocalStorage.preferredLanguage ?? NotificareUtils.deviceLanguage
    }

    private func getDeviceRegion() -> String {
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

        let language = getDeviceLanguage()
        let region = getDeviceRegion()

        updateLanguage(language, region: region) { result in
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
