//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

public typealias NotificareCallback<T> = (Result<T, Error>) -> Void

public class Notificare {
    public static let shared = Notificare()

    public static var SDK_VERSION: String {
        NOTIFICARE_VERSION
    }

    // Internal modules
    internal let database = NotificareDatabase()
    internal private(set) var reachability: NotificareReachability?

    // Configuration variables
    public private(set) var servicesInfo: NotificareServicesInfo?
    public private(set) var options: NotificareOptions?

    // Launch / application state
    internal private(set) var state: NotificareLaunchState = .none

    public private(set) var application: NotificareApplication? {
        get {
            LocalStorage.application
        }
        set {
            LocalStorage.application = newValue
        }
    }

    public weak var delegate: NotificareDelegate?

    private init() {}

    // MARK: - Public API

    public var isConfigured: Bool {
        state >= .configured
    }

    public var isReady: Bool {
        state == .ready
    }

    public var canEvaluateDeferredLink: Bool {
        guard LocalStorage.deferredLinkChecked == false else {
            return false
        }

        return UIPasteboard.general.hasURLs
    }

    public func configure(servicesInfo: NotificareServicesInfo? = nil, options: NotificareOptions? = nil) {
        configure(
            servicesInfo: servicesInfo ?? loadServiceInfoFile(),
            options: options ?? loadOptionsFile()
        )
    }

    public func configure(servicesInfo: NotificareServicesInfo, options: NotificareOptions) {
        guard state == .none else {
            NotificareLogger.warning("Notificare has already been configured. Skipping...")
            return
        }

        do {
            try servicesInfo.validate()
        } catch {
            fatalError("Could not validate the provided services configuration. Please check the contents are valid.")
        }

        self.servicesInfo = servicesInfo
        self.options = options

        if !LocalStorage.migrated {
            NotificareLogger.debug("Checking if there is legacy data that needs to be migrated.")
            let migration = LocalStorageMigration()

            if migration.hasLegacyData {
                migration.migrate()
                NotificareLogger.info("Legacy data found and migrated to the new storage format.")
            }

            LocalStorage.migrated = true
        }

        // The default value of the deferred link depends on whether Notificare has a registered device.
        // Having a registered device means the app ran at least once and we should stop checking for
        // deferred links.
        if LocalStorage.deferredLinkChecked == nil {
            LocalStorage.deferredLinkChecked = LocalStorage.device != nil
        }

        NotificareLogger.debug("Configuring network services.")
        configureReachability(servicesInfo: servicesInfo)

        if options.swizzlingEnabled {
            var swizzleApns = false

            // Check if the Push module is loaded.
            if NotificareInternals.Module.push.isAvailable {
                swizzleApns = true
            }

            NotificareSwizzler.setup(withRemoteNotifications: swizzleApns)
        } else {
            NotificareLogger.warning("""
            Automatic App Delegate Proxy is not enabled. \
            You will need to forward UIAppDelegate events to Notificare manually. \
            Please check the documentation for which events to forward.
            """)
        }

        NotificareLogger.debug("Configuring available modules.")
        database.configure()

        NotificareInternals.Module.allCases.forEach { module in
            if let instance = module.klass?.instance {
                NotificareLogger.debug("Configuring module: \(module)")
                instance.configure()
            }
        }

        NotificareLogger.debug("Notificare configured all services.")
        state = .configured

        if !servicesInfo.hasDefaultHosts {
            NotificareLogger.info("Notificare configured with customized hosts.")
            NotificareLogger.debug("REST API host: \(servicesInfo.hosts.restApi)")
            NotificareLogger.debug("AppLinks host: \(servicesInfo.hosts.appLinks)")
            NotificareLogger.debug("Short Links host: \(servicesInfo.hosts.shortLinks)")
        }
    }

    public func launch(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await launch()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func launch() async throws {
        if state == .none {
            NotificareLogger.debug("Notificare wasn't configured. Configuring before launching.")
            configure()
        }

        if state > .configured {
            NotificareLogger.warning("Notificare has already been launched. Skipping...")
            return
        }

        NotificareLogger.info("Launching Notificare.")
        state = .launching

        do {
            // Start listening for reachability events.
            NotificareLogger.debug("Start listening to reachability events.")
            try reachability!.startNotifier()
        } catch {
            NotificareLogger.error("Failed to start listening to reachability events.", error: error)
            fatalError("Failed to start listening to reachability events.")
        }

        do {
            let application = try await fetchApplication(saveToLocalStorage: false)
            let storedApplication = LocalStorage.application

            if let storedApplication, storedApplication.id != application.id {
                NotificareLogger.warning("Incorrect application keys detected. Resetting Notificare to a clean state.")

                for module in NotificareInternals.Module.allCases {
                    if let instance = module.klass?.instance {
                        NotificareLogger.debug("Resetting module: \(module)")

                        do {
                            try await instance.clearStorage()
                        } catch {
                            NotificareLogger.debug("Failed to reset '\(module)'.", error: error)
                            throw error
                        }
                    }
                }

                try database.clear()
                LocalStorage.clear()
            }

            LocalStorage.application = application

            // Loop all possible modules and launch the available ones.
            for module in NotificareInternals.Module.allCases {
                if let instance = module.klass?.instance {
                    NotificareLogger.debug("Launching module: \(module)")

                    do {
                        try await instance.launch()
                    } catch {
                        NotificareLogger.debug("Failed to launch '\(module)'.", error: error)
                        throw error
                    }
                }
            }

            state = .ready
            printLaunchSummary(application: application)

            DispatchQueue.main.async {
                // We're done launching. Notify the delegate.
                self.delegate?.notificare(self, onReady: application)
            }
        } catch {
            NotificareLogger.error("Failed to launch Notificare.", error: error)
            state = .configured
            throw error
        }

        Task {
            // Loop all possible modules and post-launch the available ones.
            for module in NotificareInternals.Module.allCases {
                if let instance = module.klass?.instance {
                    do {
                        NotificareLogger.debug("Post-launching module: \(module)")
                        try await instance.postLaunch()
                    } catch {
                        NotificareLogger.error("Failed to post-launch '\(module)'.", error: error)
                    }
                }
            }
        }
    }

    public func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await unlaunch()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func unlaunch() async throws {
        guard isReady else {
            NotificareLogger.warning("Cannot un-launch Notificare before it has been launched.")
            return
        }

        NotificareLogger.info("Un-launching Notificare.")

        // Loop all possible modules and un-launch the available ones.
        for module in NotificareInternals.Module.allCases.reversed() {
            if let instance = module.klass?.instance {
                NotificareLogger.debug("Un-launching module: \(module)")

                do {
                    try await instance.unlaunch()
                } catch {
                    NotificareLogger.debug("Failed to un-launch '\(module)'.", error: error)
                    throw error
                }
            }
        }

        NotificareLogger.debug("Removing device.")
        try await self.deviceImplementation().delete()

        NotificareLogger.info("Un-launched Notificare.")
        self.state = .configured

        DispatchQueue.main.async {
            self.delegate?.notificareDidUnlaunch(self)
        }
    }

    public func fetchApplication(_ completion: @escaping NotificareCallback<NotificareApplication>) {
        Task {
            do {
                let result = try await fetchApplication()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchApplication() async throws -> NotificareApplication {
        return try await fetchApplication(saveToLocalStorage: true)
    }

    public func fetchDynamicLink(_ link: String, _ completion: @escaping NotificareCallback<NotificareDynamicLink>) {
        Task {
            do {
                let result = try await fetchDynamicLink(link)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchDynamicLink(_ link: String) async throws -> NotificareDynamicLink {
        guard isConfigured else {
            throw NotificareError.notConfigured
        }

        guard let urlEncodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NotificareError.invalidArgument(message: "Invalid link value.")
        }

        let response = try await NotificareRequest.Builder()
            .get("/link/dynamic/\(urlEncodedLink)")
            .query(name: "platform", value: "iOS")
            .query(name: "deviceID", value: Notificare.shared.device().currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.device().currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.DynamicLink.self)

        return response.link
    }

    public func fetchNotification(_ id: String, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        Task {
            do {
                let result = try await fetchNotification(id)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchNotification(_ id: String) async throws -> NotificareNotification {
        guard isConfigured else {
            throw NotificareError.notConfigured
        }

        guard let urlEncodedId = id.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NotificareError.invalidArgument(message: "Invalid id value.")
        }

        let response = try await NotificareRequest.Builder()
            .get("/notification/\(urlEncodedId)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Notification.self)

        return response.notification.toModel()
    }

    public func createNotificationReply(notification: NotificareNotification, action: NotificareNotification.Action, message: String? = nil, media: String? = nil, mimeType: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await createNotificationReply(notification: notification, action: action, message: message, media: media, mimeType: mimeType)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func createNotificationReply(notification: NotificareNotification, action: NotificareNotification.Action, message: String? = nil, media: String? = nil, mimeType: String? = nil) async throws {
        guard isConfigured else {
            throw NotificareError.notConfigured
        }

        guard let device = device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let payload = NotificareInternals.PushAPI.Payloads.CreateNotificationReply(
            notification: notification.id,
            deviceID: device.id,
            userID: device.userId,
            label: action.label,
            data: NotificareInternals.PushAPI.Payloads.CreateNotificationReply.ReplyData(
                target: action.target,
                message: message,
                media: media,
                mimeType: mimeType
            )
        )

        try await NotificareRequest.Builder()
            .post("/reply", body: payload)
            .response()
    }

    public func callNotificationReplyWebhook(url: URL, data: [String: String], _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await callNotificationReplyWebhook(url: url, data: data)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func callNotificationReplyWebhook(url: URL, data: [String: String]) async throws {
        var params = [String: String]()

        // Add all query params to the POST body.
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    params[item.name] = value
                }
            }
        }

        // Add our standard properties.
        params["userID"] = device().currentDevice?.userId
        params["deviceID"] = device().currentDevice?.id

        // Add all the items passed via data.
        data.forEach { params[$0.key] = $0.value }

        try await NotificareRequest.Builder()
            .post(url.absoluteString, body: params)
            .response()
    }

    public func uploadNotificationReplyAsset(_ data: Data, contentType: String, _ completion: @escaping NotificareCallback<String>) {
        Task {
            do {
                let result = try await uploadNotificationReplyAsset(data, contentType: contentType)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func uploadNotificationReplyAsset(_ data: Data, contentType: String) async throws -> String {
        guard isConfigured else {
            throw NotificareError.notConfigured
        }

        let response = try await NotificareRequest.Builder()
            .post("/upload/reply", body: data, contentType: contentType)
            .responseDecodable(NotificareInternals.PushAPI.Responses.UploadAsset.self)

        let host = Notificare.shared.servicesInfo!.hosts.restApi

        return "https://\(host)/upload\(response.filename)"
    }

    public func removeNotificationFromNotificationCenter(_ notification: NotificareNotification) {
        removeNotificationFromNotificationCenter(notification.id)
    }

    public func removeNotificationFromNotificationCenter(_ notificationId: String) {
        NotificareLogger.debug("Removing notification '\(notificationId)' from the notification center.")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationId])
    }

    public func handleTestDeviceUrl(_ url: URL) -> Bool {
        guard let nonce = parseTestDeviceNonce(url: url) else {
            return false
        }

        Task {
            do {
                try await deviceImplementation().registerTestDevice(nonce: nonce)
                NotificareLogger.info("Device registered for testing.")
            } catch {
                NotificareLogger.error("Failed to register the device for testing.", error: error)
            }
        }

        return true
    }

    public func handleDynamicLinkUrl(_ url: URL) -> Bool {
        guard let url = parseDynamicLink(url: url) else {
            return false
        }

        Task {
            do {
                NotificareLogger.debug("Handling a dynamic link.")
                let link = try await fetchDynamicLink(url.absoluteString)

                guard let targetUrl = URL(string: link.target) else {
                    NotificareLogger.warning("Failed to parse the dynamic link target url.")
                    return
                }

                DispatchQueue.main.async {
                    UIApplication.shared.open(targetUrl, options: [:]) { opened in
                        if !opened {
                            NotificareLogger.warning("The dynamic link's target was not handled by the application.")
                        }
                    }
                }
            } catch {
                NotificareLogger.warning("Failed to fetch the dynamic link.", error: error)
            }
        }

        return true
    }

    @MainActor
    public func evaluateDeferredLink() async throws -> Bool {
        guard LocalStorage.deferredLinkChecked == false else {
            NotificareLogger.debug("Deferred link already evaluated.")
            return false
        }

        defer {
            LocalStorage.deferredLinkChecked = true
        }

        guard UIPasteboard.general.hasURLs else {
            NotificareLogger.debug("Detected URLs in the clipboard.")
            return false
        }

        guard let deferredUrl = UIPasteboard.general.url else {
            NotificareLogger.warning("Detected URLs in the clipboard but the user denied access.")
            return false
        }

        let dynamicLink = try await fetchDynamicLink(deferredUrl.absoluteString)

        guard let url = URL(string: dynamicLink.target) else {
            NotificareLogger.warning("Failed to parse the dynamic link target url.")
            return false
        }

        guard UIApplication.shared.canOpenURL(url) else {
            NotificareLogger.warning("Cannot open a deep link that's not supported by the application.")
            return false
        }

        defer {
            UIPasteboard.general.items = []
        }

        return await UIApplication.shared.open(url)
    }

    public func evaluateDeferredLink(_ completion: @escaping NotificareCallback<Bool>) {
        Task {
            do {
                let result = try await evaluateDeferredLink()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private API

    private func configureReachability(servicesInfo: NotificareServicesInfo) {
        do {
            let url = URL(string: "https://\(servicesInfo.hosts.restApi)")!
            reachability = try NotificareReachability(hostname: url.host!)

            reachability?.whenReachable = { _ in
                NotificareLogger.debug("Notificare is reachable.")
            }

            reachability?.whenUnreachable = { _ in
                NotificareLogger.debug("Notificare is unreachable.")
            }
        } catch {
            fatalError("Failed to configure the reachability module: \(error.localizedDescription)")
        }
    }

    private func printLaunchSummary(application: NotificareApplication) {
        let enabledServices = application.services.filter(\.value).map(\.key)
        let enabledModules = NotificareUtils.getEnabledPeerModules()

        NotificareLogger.info("Notificare is ready to use for application.")
        NotificareLogger.debug("/==================================================================================/")
        NotificareLogger.debug("App name: \(application.name)")
        NotificareLogger.debug("App ID: \(application.id)")
        NotificareLogger.debug("App services: \(enabledServices.joined(separator: ", "))")
        NotificareLogger.debug("/==================================================================================/")
        NotificareLogger.debug("SDK version: \(Notificare.SDK_VERSION)")
        NotificareLogger.debug("SDK modules: \(enabledModules.joined(separator: ", "))")
        NotificareLogger.debug("/==================================================================================/")
    }

    private func loadServiceInfoFile() -> NotificareServicesInfo {
        guard let path = Bundle.main.path(forResource: NotificareServicesInfo.fileName, ofType: NotificareServicesInfo.fileExtension) else {
            fatalError("\(NotificareServicesInfo.fileName).\(NotificareServicesInfo.fileExtension) is missing.")
        }

        guard let servicesInfo = NotificareServicesInfo(contentsOfFile: path) else {
            fatalError("Could not parse the NotificareServices plist. Please check the contents are valid.")
        }

        return servicesInfo
    }

    private func loadOptionsFile() -> NotificareOptions {
        if let path = Bundle.main.path(forResource: NotificareOptions.fileName, ofType: NotificareOptions.fileExtension) {
            guard let options = NotificareOptions(contentsOfFile: path) else {
                fatalError("Could not parse the NotificareOptions plist. Please check the contents are valid.")
            }

            return options
        } else {
            return NotificareOptions()
        }
    }

    private func parseTestDeviceNonce(url: URL) -> String? {
        if let nonce = parseTestDeviceNonceLegacy(url: url) {
            return nonce
        }

        guard
            let application = Notificare.shared.application,
            let appLinksHost = Notificare.shared.servicesInfo?.hosts.appLinks,
            url.host == "\(application.id).\(appLinksHost)",
            url.pathComponents.count >= 3,
            url.pathComponents[1] == "testdevice"
        else {
            return nil
        }

        return url.pathComponents[2]
    }

    private func parseTestDeviceNonceLegacy(url: URL) -> String? {
        guard let application = application else { return nil }
        guard let scheme = url.scheme else { return nil }

        // deep link: test.nc{applicationId}/notifica.re/testdevice/{nonce}
        guard scheme == "test.nc\(application.id)" else { return nil }

        guard url.pathComponents.count == 3, url.pathComponents[1] == "testdevice" else { return nil }

        return url.pathComponents[2]
    }

    private func parseDynamicLink(url: URL) -> URL? {
        guard let host = url.host else {
            return nil
        }

        guard let servicesInfo = servicesInfo else {
            NotificareLogger.warning("Unable to parse dynamic link. Notificare services have not been configured.")
            return nil
        }

        guard host.matches("^([a-z0-9-])+\\.\\Q\(servicesInfo.hosts.shortLinks)\\E$".toRegex()) else {
            NotificareLogger.debug("Domain pattern wasn't a match.")
            return nil
        }

        guard url.pathComponents.count == 2 else {
            NotificareLogger.debug("Path components length wasn't a match.")
            return nil
        }

        let code = url.pathComponents[1]
        guard code.matches("^[a-zA-Z0-9_-]+$".toRegex()) else {
            NotificareLogger.debug("First path component value wasn't a match.")
            return nil
        }

        return url
    }

    private func fetchApplication(saveToLocalStorage: Bool) async throws -> NotificareApplication {
        let response = try await NotificareRequest.Builder()
            .get("/application/info")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Application.self)

        let application = response.application.toModel()

        if saveToLocalStorage {
            self.application = application
        }

        return application
    }
}
