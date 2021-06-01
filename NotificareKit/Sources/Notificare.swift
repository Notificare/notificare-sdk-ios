//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

public typealias NotificareCallback<T> = (Result<T, Error>) -> Void

public class Notificare {
    public static let shared = Notificare()

    // Internal modules
    internal let crashReporter = NotificareCrashReporter()
    internal let sessionManager = NotificareSessionManager()
    internal let database = NotificareDatabase()
    internal private(set) var reachability: NotificareReachability?

    // Consumer modules
    public let eventsManager = NotificareEventsModule()
    public let deviceManager = NotificareDeviceManager()

    // Configuration variables
    public private(set) var servicesInfo: NotificareServicesInfo?
    public private(set) var options: NotificareOptions?

    // Launch / application state
    internal private(set) var state: NotificareLaunchState = .none
    public private(set) var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    public private(set) var application: NotificareApplication? {
        get {
            LocalStorage.application
        }
        set {
            LocalStorage.application = newValue
        }
    }

    public weak var delegate: NotificareDelegate?

    public var useAdvancedLogging: Bool {
        get { NotificareLogger.useAdvancedLogging }
        set { NotificareLogger.useAdvancedLogging = newValue }
    }

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
            if (NSClassFromString(NotificareDefinitions.Modules.push.rawValue) as? NotificareModule.Type) != nil {
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
        sessionManager.configure()
        crashReporter.configure()
        database.configure()
        eventsManager.configure()
        deviceManager.configure()

        NotificareDefinitions.Modules.allCases.forEach { module in
            if let cls = NSClassFromString(module.rawValue) as? NotificareModule.Type {
                NotificareLogger.debug("Configuring plugin: \(module.rawValue)")
                cls.configure()
            }
        }

        NotificareLogger.debug("Notificare configured all services.")
        state = .configured
    }

    public func launch(_: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        if state == .none {
            NotificareLogger.warning("Notificare wasn't configured. Configuring before launching.")
            configure()
        }

        if state > .configured {
            NotificareLogger.warning("Notificare has already been launched. Skipping...")
            return
        }

        NotificareLogger.info("Launching Notificare.")
        state = .launching

        sessionManager.launch()

        do {
            // Start listening for reachability events.
            NotificareLogger.debug("Start listening to reachability events.")
            try reachability!.startNotifier()
        } catch {
            NotificareLogger.error("Failed to start listening to reachability events: \(error)")
            fatalError("Failed to start listening to reachability events: \(error)")
        }

        // Fetch the application info.
        fetchApplication { result in
            switch result {
            case let .success(application):
                // Launch the device manager: registration.
                self.deviceManager.launch { _ in
                    // Ignore the error if device registration fails.

                    // Launch the event logger
                    self.eventsManager.launch()
                    self.crashReporter.launch()

                    // Keep a reference to a possible failure during the launch of the plugins.
                    var latestPluginLaunchError: Error?

                    // Keep track of launchables and handle the outcome once they have all finished launching.
                    let dispatchGroup = DispatchGroup()

                    // Loop all possible modules and launch the available ones.
                    NotificareDefinitions.Modules.allCases.forEach { module in
                        if let cls = NSClassFromString(module.rawValue) as? NotificareModule.Type {
                            dispatchGroup.enter()

                            NotificareLogger.debug("Launching '\(module.rawValue)' plugin.")
                            cls.launch { result in
                                switch result {
                                case .success:
                                    NotificareLogger.debug("Launched '\(module.rawValue)' successfully.")
                                case let .failure(error):
                                    NotificareLogger.debug("Failed to launch '\(module.rawValue)': \(error)")
                                    latestPluginLaunchError = error
                                }

                                dispatchGroup.leave()
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        if let error = latestPluginLaunchError {
                            self.launchResult(.failure(error))
                        } else {
                            self.launchResult(.success(application))
                        }
                    }
                }
            case let .failure(error):
                NotificareLogger.error("Failed to load the application info: \(error)")
                self.launchResult(.failure(error))
            }
        }
    }

    public func unlaunch() {
        guard isReady else {
            NotificareLogger.warning("Cannot un-launch Notificare before it has been launched.")
            return
        }

        NotificareLogger.info("Un-launching Notificare.")

        deviceManager.registerTemporary { result in
            switch result {
            case .success:
                NotificareLogger.debug("Registered device as temporary.")

                // Keep a reference to a possible failure during the launch of the plugins.
                var latestPluginUnlaunchError: Error?

                // Keep track of launchables and handle the outcome once they have all finished launching.
                let dispatchGroup = DispatchGroup()

                // Loop all possible modules and un-launch the available ones.
                NotificareDefinitions.Modules.allCases.reversed().forEach { module in
                    if let cls = NSClassFromString(module.rawValue) as? NotificareModule.Type {
                        dispatchGroup.enter()

                        NotificareLogger.debug("Un-launching '\(module.rawValue)' plugin.")
                        cls.unlaunch { result in
                            switch result {
                            case .success:
                                NotificareLogger.debug("Un-launched '\(module.rawValue)' successfully.")
                            case let .failure(error):
                                NotificareLogger.debug("Failed to un-launch '\(module.rawValue)': \(error)")
                                latestPluginUnlaunchError = error
                            }

                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if latestPluginUnlaunchError == nil {
                        self.deviceManager.clearTags { result in
                            switch result {
                            case .success:
                                NotificareLogger.debug("Removed all device tags.")

                                self.deviceManager.delete { result in
                                    switch result {
                                    case .success:
                                        NotificareLogger.debug("Removed the device.")

                                        NotificareLogger.info("Un-launched Notificare.")
                                        self.state = .configured

                                    case let .failure(error):
                                        NotificareLogger.error("Failed to delete device: \(error)")
                                    }
                                }

                            case let .failure(error):
                                NotificareLogger.error("Failed to clear device tags: \(error)")
                            }
                        }
                    }
                }

            case let .failure(error):
                NotificareLogger.error("Failed to register temporary device: \(error)")
            }
        }
    }

    public func fetchApplication(_ completion: @escaping NotificareCallback<NotificareApplication>) {
        NotificareRequest.Builder()
            .get("/application/info")
            .responseDecodable(PushAPI.Responses.Application.self) { result in
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
            .query(name: "deviceID", value: Notificare.shared.deviceManager.currentDevice?.id)
            .query(name: "userID", value: Notificare.shared.deviceManager.currentDevice?.userId)
            .responseDecodable(PushAPI.Responses.DynamicLink.self) { result in
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
            .responseDecodable(PushAPI.Responses.Notification.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.notification.toModel()))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func createNotificationReply(notification: NotificareNotification, action: NotificareNotification.Action, message: String? = nil, media: String? = nil, mimeType: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        guard isReady, let device = deviceManager.currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        let payload = PushAPI.Payloads.CreateNotificationReply(
            notification: notification.id,
            deviceID: device.id,
            userID: device.userId,
            label: action.label,
            data: PushAPI.Payloads.CreateNotificationReply.ReplyData(
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
        params["userID"] = deviceManager.currentDevice?.userId
        params["deviceID"] = deviceManager.currentDevice?.id

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
            .responseDecodable(PushAPI.Responses.UploadAsset.self) { result in
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

        deviceManager.registerTestDevice(nonce: nonce) { result in
            switch result {
            case .success:
                NotificareLogger.info("Device registered for testing.")
            case let .failure(error):
                NotificareLogger.error("Failed to register the device for testing.\n\(error)")
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

    private func launchResult(_ result: Result<NotificareApplication, Error>) {
        switch result {
        case let .success(application):
            state = .ready

            let enabledServices = application.services.filter(\.value).map(\.key)
            let enabledModules = NotificareUtils.getLoadedModules()

            NotificareLogger.debug("/==================================================================================/")
            NotificareLogger.debug("Notificare SDK is ready to use for application")
            NotificareLogger.debug("App name: \(application.name)")
            NotificareLogger.debug("App ID: \(application.id)")
            NotificareLogger.debug("App services: \(enabledServices.joined(separator: ", "))")
            NotificareLogger.debug("/==================================================================================/")
            NotificareLogger.debug("SDK version: \(NotificareDefinitions.sdkVersion)")
            NotificareLogger.debug("SDK modules: \(enabledModules.joined(separator: ", "))")
            NotificareLogger.debug("/==================================================================================/")

            // We're done launching. Notify the delegate.
            delegate?.notificare(self, onReady: application)
        case .failure:
            NotificareLogger.error("Failed to launch Notificare.")
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
}
