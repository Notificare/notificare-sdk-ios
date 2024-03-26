//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

internal class NotificareDeviceModuleImpl: NSObject, NotificareModule, NotificareDeviceModule, NotificareInternalDeviceModule {
    // MARK: - Notificare Module

    internal static let instance = NotificareDeviceModuleImpl()

    internal func configure() {
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

    internal func launch() async throws {
        if let device = currentDevice {
            do {
                try await register(transport: device.transport, token: device.id, userId: device.userId, userName: device.userName)
            } catch {
                NotificareLogger.warning("Failed to register device.", error: error)
                throw error
            }

            do {
                try await Notificare.shared.session().launch()

                if device.appVersion != NotificareUtils.applicationVersion {
                    // It's not the same version, let's log it as an upgrade.
                    NotificareLogger.debug("New version detected")
                    try? await Notificare.shared.eventsImplementation().logApplicationUpgrade()
                }
            } catch {
                NotificareLogger.debug("Failed to launch the session module.", error: error)
                throw error
            }
        } else {
            NotificareLogger.debug("New install detected")

            do {
                try await registerTemporary()
            } catch {
                NotificareLogger.warning("Failed to register temporary device.", error: error)
                throw error
            }

            do {
                try await Notificare.shared.session().launch()

                // We will log the Install & Registration events here since this will execute only one time at the start.
                try? await Notificare.shared.eventsImplementation().logApplicationInstall()
                try? await Notificare.shared.eventsImplementation().logApplicationRegistration()
            } catch {
                NotificareLogger.debug("Failed to launch the session module.", error: error)
                throw error
            }
        }
    }

    internal func postLaunch() async throws {
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
        Task {
            do {
                try await register(userId: userId, userName: userName)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func register(userId: String?, userName: String?) async throws {
        guard Notificare.shared.isReady,
              let device = currentDevice
        else {
            throw NotificareError.notReady
        }

        try await register(transport: device.transport, token: device.id, userId: userId, userName: userName)
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updatePreferredLanguage(preferredLanguage)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func updatePreferredLanguage(_ preferredLanguage: String?) async throws {
        guard Notificare.shared.isReady else {
            throw NotificareError.notReady
        }

        if let preferredLanguage = preferredLanguage {
            let parts = preferredLanguage.components(separatedBy: "-")

            // TODO: improve language validator
            guard parts.count == 2 else {
                NotificareLogger.error("Not a valid preferred language. Use a ISO 639-1 language code and a ISO 3166-2 region code (e.g. en-US).")
                throw NotificareError.invalidArgument(message: "Invalid preferred language value '\(preferredLanguage)'.")
            }

            let language = parts[0]
            let region = parts[1]

            // Only update if the value is not the same.
            guard language != LocalStorage.preferredLanguage, region != LocalStorage.preferredRegion else {
                return
            }

            try await updateLanguage(language, region: region)

            LocalStorage.preferredLanguage = language
            LocalStorage.preferredRegion = region
        } else {
            let language = NotificareUtils.deviceLanguage
            let region = NotificareUtils.deviceRegion

            try await updateLanguage(language, region: region)

            LocalStorage.preferredLanguage = nil
            LocalStorage.preferredRegion = nil
        }
    }

    public func fetchTags(_ completion: @escaping NotificareCallback<[String]>) {
        Task {
            do {
                let result = try await fetchTags()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchTags() async throws -> [String] {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/device/\(device.id)/tags")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Tags.self)

        return response.tags
    }

    public func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await addTag(tag)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func addTag(_ tag: String) async throws {
        try await addTags([tag])
    }

    public func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await addTags(tags)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func addTags(_ tags: [String]) async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/addtags", body: NotificareInternals.PushAPI.Payloads.Device.Tags(tags: tags))
            .response()
    }

    public func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await removeTag(tag)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func removeTag(_ tag: String) async throws {
        try await removeTags([tag])
    }

    public func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await removeTags(tags)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func removeTags(_ tags: [String]) async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/removetags", body: NotificareInternals.PushAPI.Payloads.Device.Tags(tags: tags))
            .response()
    }

    public func clearTags(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await clearTags()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func clearTags() async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/cleartags")
            .response()
    }

    public func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>) {
        Task {
            do {
                let result = try await fetchDoNotDisturb()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchDoNotDisturb() async throws -> NotificareDoNotDisturb? {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/device/\(device.id)/dnd")
            .responseDecodable(NotificareInternals.PushAPI.Responses.DoNotDisturb.self)
        // Update current device properties.
        currentDevice?.dnd = response.dnd
        return response.dnd
    }

    public func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updateDoNotDisturb(dnd)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb) async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/dnd", body: dnd)
            .response()
        // Update current device properties.
        currentDevice?.dnd = dnd
    }

    public func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await clearDoNotDisturb()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func clearDoNotDisturb() async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/cleardnd")
            .response()
        // Update current device properties.
        currentDevice?.dnd = nil
    }

    public func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData>) {
        Task {
            do {
                let result = try await fetchUserData()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchUserData() async throws -> NotificareUserData {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/device/\(device.id)/userdata")
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserData.self)
        let userData = response.userData?.compactMapValues { $0 } ?? [:]
        // Update current device properties.
        currentDevice?.userData = userData
        return userData
    }

    public func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updateUserData(userData)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func updateUserData(_ userData: NotificareUserData) async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)/userdata", body: userData)
            .response()

        // Update current device properties.
        currentDevice?.userData = userData
    }

    // MARK: - Notificare Internal Device Module

    public func registerTemporary() async throws {
        var token = withUnsafePointer(to: UUID().uuid) {
            Data(bytes: $0, count: 16)
        }.toHexString()

        // NOTE: keep the same token if available and only when not changing transport providers.
        if let device = currentDevice, device.transport == .notificare {
            token = device.id
        }

        try await register(transport: .notificare, token: token, userId: currentDevice?.userId, userName: currentDevice?.userName)
    }

    public func registerAPNS(token: String, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await registerAPNS(token: token)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func registerAPNS(token: String) async throws {
        try await register(transport: .apns, token: token, userId: currentDevice?.userId, userName: currentDevice?.userName)
    }

    // MARK: - Internal API

    internal func delete(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await delete()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    internal func delete() async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .delete("/device/\(device.id)")
            .response()

        // Update current device properties.
        currentDevice = nil
    }

    internal func updateTimezone(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updateTimezone()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    internal func updateTimezone() async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateTimeZone(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            timeZoneOffset: NotificareUtils.timeZoneOffset
        )

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        currentDevice?.timeZoneOffset = payload.timeZoneOffset
    }

    internal func updateLanguage(_ language: String, region: String, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updateLanguage(language, region: region)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    internal func updateLanguage(_ language: String, region: String) async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateLanguage(
            language: language,
            region: region
        )

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        currentDevice?.language = payload.language
        currentDevice?.region = payload.region
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

    internal func updateBackgroundAppRefresh() async throws {
        guard Notificare.shared.isReady, let device = currentDevice else {
            throw NotificareError.notReady
        }

        let payload = await NotificareInternals.PushAPI.Payloads.Device.UpdateBackgroundAppRefresh(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            backgroundAppRefresh: UIApplication.shared.backgroundRefreshStatus == .available
        )

        try await NotificareRequest.Builder()
            .put("/device/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        currentDevice?.backgroundAppRefresh = payload.backgroundAppRefresh
    }

    private func register(transport: NotificareTransport, token: String, userId: String?, userName: String?) async throws {
        if registrationChanged(token: token, userId: userId, userName: userName) {
            // NOTE: the backgroundRefreshStatus will print a warning when accessed from background threads.
            let oldDeviceId = currentDevice?.id != nil && currentDevice?.id != token ? currentDevice?.id : nil

            let deviceRegistration = await NotificareInternals.PushAPI.Payloads.Device.Registration(
                deviceID: token,
                oldDeviceID: oldDeviceId,
                userID: userId,
                userName: userName,
                language: getDeviceLanguage(),
                region: getDeviceRegion(),
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

            do {
                try await NotificareRequest.Builder()
                    .post("/device", body: deviceRegistration)
                    .response()
                let device = NotificareDevice(from: deviceRegistration, previous: currentDevice)

                // Update and store the cached device.
                currentDevice = device

                if Notificare.shared.isReady {
                    DispatchQueue.main.async {
                        // Notify delegate.
                        Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: device)
                    }
                }
            } catch {
                NotificareLogger.error("Failed to register device.", error: error)
            }
        } else {
            NotificareLogger.info("Skipping device registration, nothing changed.")

            if Notificare.shared.isReady {
                DispatchQueue.main.async {
                    Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: self.currentDevice!)
                }
            }
        }
    }

    internal func registerTestDevice(nonce: String, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await registerTestDevice(nonce: nonce)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        /*
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
         */
    }

    internal func registerTestDevice(nonce: String) async throws {
        guard let device = currentDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.TestDeviceRegistration(
            deviceID: device.id
        )

        try await NotificareRequest.Builder()
            .put("/support/testdevice/\(nonce)", body: payload)
            .response()
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

        Task {
            try? await updateTimezone()
            NotificareLogger.info("Device timezone updated.")
        }
    }

    @objc private func updateDeviceLanguage() {
        NotificareLogger.info("Device language changed.")

        let language = getDeviceLanguage()
        let region = getDeviceRegion()

        Task {
            try? await updateLanguage(language, region: region)
            NotificareLogger.info("Device language updated.")
        }
    }

    @objc private func updateDeviceBackgroundAppRefresh() {
        NotificareLogger.info("Device background app refresh status changed.")

        Task {
            try? await updateBackgroundAppRefresh()
            NotificareLogger.info("Device background app refresh status updated.")
        }
    }
}
