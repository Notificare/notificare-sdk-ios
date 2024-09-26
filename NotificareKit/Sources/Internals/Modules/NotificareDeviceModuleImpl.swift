//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit
import NotificareUtilitiesKit

internal class NotificareDeviceModuleImpl: NSObject, NotificareModule, NotificareDeviceModule {

    internal static let instance = NotificareDeviceModuleImpl()

    internal private(set) var storedDevice: StoredDevice? {
        get { LocalStorage.device }
        set { LocalStorage.device = newValue }
    }

    private var hasPendingDeviceRegistrationEvent: Bool?

    // MARK: - Notificare Module

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
        try await upgradeToLongLivedDeviceWhenNeeded()

        if let storedDevice {
            let isApplicationUpgrade = storedDevice.appVersion != ApplicationUtils.applicationVersion

            try await updateDevice()

            // Ensure a session exists for the current device.
            try await Notificare.shared.session().launch()

            if isApplicationUpgrade {
                // It's not the same version, let's log it as an upgrade.
                NotificareLogger.debug("New version detected")
                try? await Notificare.shared.eventsImplementation().logApplicationUpgrade()
            }
        } else {
            NotificareLogger.debug("New install detected")

            try await createDevice()
            hasPendingDeviceRegistrationEvent = true

            // Ensure a session exists for the current device.
            try await Notificare.shared.session().launch()

            // We will log the Install & Registration events here since this will execute only one time at the start.
            try? await Notificare.shared.eventsImplementation().logApplicationInstall()
            try? await Notificare.shared.eventsImplementation().logApplicationRegistration()
        }
    }

    internal func postLaunch() async throws {
        if let storedDevice, hasPendingDeviceRegistrationEvent == true {
            DispatchQueue.main.async {
                Notificare.shared.delegate?.notificare(Notificare.shared, didRegisterDevice: storedDevice.asPublic())
            }
        }
    }

    // MARK: - Notificare Device Module

    public var currentDevice: NotificareDevice? {
        storedDevice?.asPublic()
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
        updateUser(userId: userId, userName: userName, completion)
    }

    public func register(userId: String?, userName: String?) async throws {
        try await updateUser(userId: userId, userName: userName)
    }

    public func updateUser(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await updateUser(userId: userId, userName: userName)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func updateUser(userId: String?, userName: String?) async throws {
        // TODO: try checkPrerequisites()

        guard Notificare.shared.isReady else {
            throw NotificareError.notReady
        }

        guard var device = storedDevice else {
            throw NotificareError.deviceUnavailable
        }

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceUser(
            userID: userId,
            userName: userName
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        device.userId = userId
        device.userName = userName

        self.storedDevice = device
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
            let language = DeviceUtils.deviceLanguage
            let region = DeviceUtils.deviceRegion

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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/push/\(device.id)/tags")
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.Tags(
            tags: tags
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)/addtags", body: payload)
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.Tags(
            tags: tags
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)/removetags", body: payload)
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)/cleartags")
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/push/\(device.id)/dnd")
            .responseDecodable(NotificareInternals.PushAPI.Responses.DoNotDisturb.self)

        // Update current device properties.
        storedDevice?.dnd = response.dnd

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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceDoNotDisturb(
            dnd: dnd
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.dnd = dnd
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceDoNotDisturb(
            dnd: nil
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.dnd = nil
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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let response = try await NotificareRequest.Builder()
            .get("/push/\(device.id)/userdata")
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserData.self)

        let userData = response.userData?.compactMapValues { $0 } ?? [:]

        // Update current device properties.
        storedDevice?.userData = userData

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
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceUserData(
            userData: userData
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.userData = userData
    }

    // MARK: - Internal API

    // TODO: check prerequisites

    private func createDevice() async throws {
        let backgroundRefreshStatus = await UIApplication.shared.backgroundRefreshStatus

        let payload = NotificareInternals.PushAPI.Payloads.CreateDevice(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            platform: "iOS",
            osVersion: DeviceUtils.osVersion,
            sdkVersion: NOTIFICARE_VERSION,
            appVersion: ApplicationUtils.applicationVersion,
            deviceString: DeviceUtils.deviceString,
            timeZoneOffset: DeviceUtils.timeZoneOffset,
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        let response = try await NotificareRequest.Builder()
            .post("/push", body: payload)
            .responseDecodable(NotificareInternals.PushAPI.Responses.CreateDevice.self)

        self.storedDevice = StoredDevice(
            id: response.device.deviceID,
            userId: nil,
            userName: nil,
            timeZoneOffset: payload.timeZoneOffset,
            osVersion: payload.osVersion,
            sdkVersion: payload.sdkVersion,
            appVersion: payload.appVersion,
            deviceString: payload.deviceString,
            language: payload.language,
            region: payload.region,
            dnd: nil,
            userData: [:],
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )
    }

    private func updateDevice() async throws {
        guard var device = storedDevice else {
            throw NotificareError.deviceUnavailable
        }

        let backgroundRefreshStatus = await UIApplication.shared.backgroundRefreshStatus

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDevice(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            platform: "iOS",
            osVersion: DeviceUtils.osVersion,
            sdkVersion: NOTIFICARE_VERSION,
            appVersion: ApplicationUtils.applicationVersion,
            deviceString: DeviceUtils.deviceString,
            timeZoneOffset: DeviceUtils.timeZoneOffset,
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        device.language = payload.language
        device.region = payload.region
        device.osVersion = payload.osVersion
        device.sdkVersion = payload.sdkVersion
        device.appVersion = payload.appVersion
        device.deviceString = payload.deviceString
        device.timeZoneOffset = payload.timeZoneOffset
        device.backgroundAppRefresh = payload.backgroundAppRefresh

        self.storedDevice = device
    }

    private func upgradeToLongLivedDeviceWhenNeeded() async throws {
        guard let device = LocalStorage.device, !device.isLongLived else {
            return
        }

        NotificareLogger.info("Upgrading current device from legacy format.")

        let deviceId = device.id
        let transport = device.transport!
        let subscriptionId = transport != "Notificare" ? deviceId : nil

        let payload = NotificareInternals.PushAPI.Payloads.UpgradeToLongLivedDevice(
            deviceID: deviceId,
            transport: transport,
            subscriptionId: subscriptionId,
            language: device.language,
            region: device.region,
            platform: "iOS",
            osVersion: device.osVersion,
            sdkVersion: device.sdkVersion,
            appVersion: device.appVersion,
            deviceString: device.deviceString,
            timeZoneOffset: device.timeZoneOffset,
            backgroundAppRefresh: device.backgroundAppRefresh
        )

        let (response, data) = try await NotificareRequest.Builder()
            .post("/push", body: payload)
            .response()

        let generatedDeviceId: String

        if response.statusCode == 201, let data {
            NotificareLogger.debug("New device identifier created.")

            let decoder = JSONUtils.jsonDecoder
            let decoded =  try decoder.decode(NotificareInternals.PushAPI.Responses.CreateDevice.self, from: data)

            generatedDeviceId = decoded.device.deviceID
        } else {
            generatedDeviceId = device.id
        }

        self.storedDevice = StoredDevice(
            id: generatedDeviceId,
            userId: device.userId,
            userName: device.userName,
            timeZoneOffset: device.timeZoneOffset,
            osVersion: device.osVersion,
            sdkVersion: device.sdkVersion,
            appVersion: device.appVersion,
            deviceString: device.deviceString,
            language: device.language,
            region: device.region,
            dnd: device.dnd,
            userData: device.userData,
            backgroundAppRefresh: device.backgroundAppRefresh
        )
    }

    internal func delete() async throws {
        // TODO: checkPrerequisites()

        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        try await NotificareRequest.Builder()
            .delete("/push/\(device.id)")
            .response()

        // Remove current device.
        storedDevice = nil
    }

    internal func updateTimezone() async throws {
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateTimeZone(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            timeZoneOffset: DeviceUtils.timeZoneOffset
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.timeZoneOffset = payload.timeZoneOffset
    }

    internal func updateLanguage(_ language: String, region: String) async throws {
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateLanguage(
            language: language,
            region: region
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.language = payload.language
        storedDevice?.region = payload.region
    }

    internal func updateBackgroundAppRefresh() async throws {
        guard Notificare.shared.isReady, let device = storedDevice else {
            throw NotificareError.notReady
        }

        let backgroundRefreshStatus = await UIApplication.shared.backgroundRefreshStatus

        let payload = NotificareInternals.PushAPI.Payloads.Device.UpdateBackgroundAppRefresh(
            language: getDeviceLanguage(),
            region: getDeviceRegion(),
            backgroundAppRefresh: backgroundRefreshStatus == .available
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        // Update current device properties.
        storedDevice?.backgroundAppRefresh = payload.backgroundAppRefresh
    }

    internal func registerTestDevice(nonce: String) async throws {
        guard let device = storedDevice else {
            throw NotificareError.notReady
        }

        let payload = NotificareInternals.PushAPI.Payloads.TestDeviceRegistration(
            deviceID: device.id
        )

        try await NotificareRequest.Builder()
            .put("/support/testdevice/\(nonce)", body: payload)
            .response()
    }

    private func getDeviceLanguage() -> String {
        LocalStorage.preferredLanguage ?? DeviceUtils.deviceLanguage
    }

    private func getDeviceRegion() -> String {
        LocalStorage.preferredRegion ?? DeviceUtils.deviceRegion
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
