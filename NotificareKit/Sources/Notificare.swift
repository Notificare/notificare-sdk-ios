//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

public typealias NotificareCallback<T> = (Result<T, Error>) -> Void

public class Notificare {
    public static let shared = Notificare()

    public static var SDK_VERSION: String {
        let bundle = Bundle(for: Self.self)
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String

        return version ?? ""
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

        NotificareLogger.debug("Configuring network services.")
        configureReachability(services: servicesInfo.services)

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
            if let instance = module.instance {
                NotificareLogger.debug("Configuring module: \(module)")
                instance.configure()
            }
        }

        NotificareLogger.debug("Notificare configured all services.")
        state = .configured
    }

    public func launch() {
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

        // Fetch the application info.
        fetchApplication { result in
            switch result {
            case let .success(application):
                // Keep a reference to a possible failure during the launch of the plugins.
                var latestPluginLaunchError: Error?

                // Keep track of launchables and handle the outcome once they have all finished launching.
                let dispatchGroup = DispatchGroup()

                // Loop all possible modules and launch the available ones.
                NotificareInternals.Module.allCases.forEach { module in
                    if let instance = module.instance {
                        dispatchGroup.enter()

                        NotificareLogger.debug("Launching module: \(module)")
                        instance.launch { result in
                            if case let .failure(error) = result {
                                NotificareLogger.debug("Failed to launch '\(module)'.", error: error)
                                latestPluginLaunchError = error
                            }

                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if let error = latestPluginLaunchError {
                        self.handleLaunchResult(.failure(error))
                    } else {
                        self.handleLaunchResult(.success(application))
                    }
                }
            case let .failure(error):
                NotificareLogger.error("Failed to load the application info.")
                self.handleLaunchResult(.failure(error))
            }
        }
    }

    public func unlaunch() {
        guard isReady else {
            NotificareLogger.warning("Cannot un-launch Notificare before it has been launched.")
            return
        }

        NotificareLogger.info("Un-launching Notificare.")

        deviceImplementation().registerTemporary { result in
            switch result {
            case .success:
                NotificareLogger.debug("Registered device as temporary.")

                // Keep a reference to a possible failure during the launch of the plugins.
                var latestPluginUnlaunchError: Error?

                // Keep track of launchables and handle the outcome once they have all finished launching.
                let dispatchGroup = DispatchGroup()

                // Loop all possible modules and un-launch the available ones.
                NotificareInternals.Module.allCases.reversed().forEach { module in
                    if let instance = module.instance {
                        dispatchGroup.enter()

                        NotificareLogger.debug("Un-launching module: \(module.rawValue)")
                        instance.unlaunch { result in
                            if case let .failure(error) = result {
                                NotificareLogger.debug("Failed to un-launch '\(module.rawValue)'.", error: error)
                                latestPluginUnlaunchError = error
                            }

                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if latestPluginUnlaunchError == nil {
                        self.device().clearTags { result in
                            switch result {
                            case .success:
                                NotificareLogger.debug("Removed all device tags.")

                                self.deviceImplementation().delete { result in
                                    switch result {
                                    case .success:
                                        NotificareLogger.debug("Removed the device.")

                                        NotificareLogger.info("Un-launched Notificare.")
                                        self.state = .configured

                                    case let .failure(error):
                                        NotificareLogger.error("Failed to delete device.", error: error)
                                    }
                                }

                            case let .failure(error):
                                NotificareLogger.error("Failed to clear device tags.", error: error)
                            }
                        }
                    }
                }

            case let .failure(error):
                NotificareLogger.error("Failed to register temporary device.", error: error)
            }
        }
    }

    public func fetchApplication(_ completion: @escaping NotificareCallback<NotificareApplication>) {
        NotificareRequest.Builder()
            .get("/application/info")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Application.self) { result in
                switch result {
                case let .success(response):
                    let application = response.application.toModel()
                    self.application = application
                    completion(.success(application))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func fetchDynamicLink(_ link: String, _ completion: @escaping NotificareCallback<NotificareDynamicLink>) {
        let urlEncodedLink = link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        NotificareRequest.Builder()
            .get("/link/dynamic/\(urlEncodedLink)")
            .query(name: "platform", value: "iOS")
            .query(name: "deviceID", value: Notificare.shared.device().currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.device().currentDevice?.userId)
            .responseDecodable(NotificareInternals.PushAPI.Responses.DynamicLink.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.link))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func fetchNotification(_ id: String, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        NotificareRequest.Builder()
            .get("/notification/\(id)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.Notification.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.notification.toModel()))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func createNotificationReply(notification: NotificareNotification, action: NotificareNotification.Action, message: String? = nil, media: String? = nil, mimeType: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        guard isReady, let device = device().currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
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

        NotificareRequest.Builder()
            .post("/reply", body: payload)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func callNotificationReplyWebhook(url: URL, data: [String: String], _ completion: @escaping NotificareCallback<Void>) {
        var params = [String: String]()

        // Add all query params to the POST body.
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
            queryItems.forEach { item in
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

        NotificareRequest.Builder()
            .post(url.absoluteString, body: params)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func uploadNotificationReplyAsset(_ data: Data, contentType: String, _ completion: @escaping NotificareCallback<String>) {
        NotificareRequest.Builder()
            .post("/upload/reply", body: data, contentType: contentType)
            .responseDecodable(NotificareInternals.PushAPI.Responses.UploadAsset.self) { result in
                switch result {
                case let .success(response):
                    completion(.success("https://push.notifica.re/upload\(response.filename)"))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func removeNotificationFromNotificationCenter(_ notification: NotificareNotification) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            notifications.forEach {
                if let id = $0.request.content.userInfo["id"] as? String, id == notification.id {
                    NotificareLogger.debug("Removing notification '\(notification.id)' from the notification center.")
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [$0.request.identifier])
                }
            }
        }
    }

    public func handleTestDeviceUrl(_ url: URL) -> Bool {
        guard let nonce = parseTestDeviceNonce(url: url) else {
            return false
        }

        deviceImplementation().registerTestDevice(nonce: nonce) { result in
            switch result {
            case .success:
                NotificareLogger.info("Device registered for testing.")
            case let .failure(error):
                NotificareLogger.error("Failed to register the device for testing.", error: error)
            }
        }

        return true
    }

    public func handleDynamicLinkUrl(_ url: URL) -> Bool {
        guard let url = parseDynamicLink(url: url) else {
            return false
        }

        NotificareLogger.debug("Handling a dynamic link.")
        fetchDynamicLink(url.absoluteString) { result in
            switch result {
            case let .success(link):
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
            case let .failure(error):
                NotificareLogger.warning("Failed to fetch the dynamic link.", error: error)
            }
        }

        return true
    }

    // MARK: - Private API

    private func configureReachability(services: NotificareServicesInfo.Services) {
        do {
            let url = URL(string: services.pushHost)!
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

    private func handleLaunchResult(_ result: Result<NotificareApplication, Error>) {
        switch result {
        case let .success(application):
            state = .ready

            let enabledServices = application.services.filter(\.value).map(\.key)
            let enabledModules = NotificareUtils.getEnabledPeerModules()

            NotificareLogger.debug("/==================================================================================/")
            NotificareLogger.debug("Notificare SDK is ready to use for application")
            NotificareLogger.debug("App name: \(application.name)")
            NotificareLogger.debug("App ID: \(application.id)")
            NotificareLogger.debug("App services: \(enabledServices.joined(separator: ", "))")
            NotificareLogger.debug("/==================================================================================/")
            NotificareLogger.debug("SDK version: \(Notificare.SDK_VERSION)")
            NotificareLogger.debug("SDK modules: \(enabledModules.joined(separator: ", "))")
            NotificareLogger.debug("/==================================================================================/")

            // We're done launching. Notify the delegate.
            delegate?.notificare(self, onReady: application)
        case let .failure(error):
            NotificareLogger.error("Failed to launch Notificare.", error: error)
            state = .configured
        }
    }

    private func loadServiceInfoFile() -> NotificareServicesInfo {
        guard let path = Bundle.main.path(forResource: NotificareServicesInfo.fileName, ofType: NotificareServicesInfo.fileExtension) else {
            fatalError("\(NotificareServicesInfo.fileName).\(NotificareServicesInfo.fileExtension) is missing.")
        }

        guard let servicesInfo = NotificareServicesInfo(contentsOfFile: path) else {
            fatalError("Could not parse the Notificare plist. Please check the contents are valid.")
        }

        return servicesInfo
    }

    private func loadOptionsFile() -> NotificareOptions {
        if let path = Bundle.main.path(forResource: NotificareOptions.fileName, ofType: NotificareOptions.fileExtension) {
            guard let options = NotificareOptions(contentsOfFile: path) else {
                fatalError("Could not parse the Notificare options plist. Please check the contents are valid.")
            }

            return options
        } else {
            return NotificareOptions()
        }
    }

    private func parseTestDeviceNonce(url: URL) -> String? {
        guard let application = self.application else { return nil }
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

        guard host.matches("^([a-z0-9-])+\\.\\Q\(servicesInfo.services.dynamicLinksDomain)\\E$".toRegex()) else {
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
}
