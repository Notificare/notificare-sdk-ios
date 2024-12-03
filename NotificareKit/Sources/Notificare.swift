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

    /// Provides the current application metadata, if available.
    public private(set) var application: NotificareApplication? {
        get {
            LocalStorage.application
        }
        set {
            LocalStorage.application = newValue
        }
    }

    /// Specifies the delegate that handles Notificare state events.
    ///
    /// This property allows setting a delegate conforming to ``NotificareDelegate`` to respond to various SDK state events ,
    /// such as sdk ready for use, and unlaunched.
    public weak var delegate: NotificareDelegate?

    private init() {}

    // MARK: - Public API

    /// Indicates whether Notificare has been configured.
    ///
    /// This property returns `true` if Notificare is successfully configured, and `false` otherwise.
    public var isConfigured: Bool {
        state >= .configured
    }

    /// Indicates whether Notificare is ready.
    ///
    /// This property returns `true` once the SDK has completed the initialization process and is ready for use.
    public var isReady: Bool {
        state == .ready
    }

    /// Checks if a deferred link exists and can be evaluated.
    public var canEvaluateDeferredLink: Bool {
        guard LocalStorage.deferredLinkChecked == false else {
            return false
        }

        return UIPasteboard.general.hasURLs
    }

    /// Configures Notificare, optionally  with the provided services info and options objects.
    ///
    /// This method configures the SDK with the provided ``NotificareServicesInfo`` and ``NotificareOptions`` objects.
    /// If not provided, this method will try to auto-configure using the services info and options provided in the  `NotificareServices.plist` and
    /// `NotificareOptions.plist` files, if they exist.
    ///
    /// - Parameters:
    ///   - servicesInfo: The optional ``NotificareServicesInfo`` object to use for configuration.
    ///   - options: The optional ``NotificareOptions`` object to use for configuration.
    public func configure(servicesInfo: NotificareServicesInfo? = nil, options: NotificareOptions? = nil) {
        configure(
            servicesInfo: servicesInfo ?? loadServiceInfoFile(),
            options: options ?? loadOptionsFile()
        )
    }

    /// Configures Notificare with the provided services info and options objects.
    ///
    /// - Parameters:
    ///   - servicesInfo: The ``NotificareServicesInfo`` object to use for configuration.
    ///   - options: The ``NotificareOptions`` object to use for configuration.
    public func configure(servicesInfo: NotificareServicesInfo, options: NotificareOptions) {
        guard state <= .configured else {
            logger.warning("Unable to reconfigure Notificare once launched.")
            return
        }

        if state == .configured {
            logger.info("Reconfiguring Notificare with another set of application keys.")
        }

        do {
            try servicesInfo.validate()
        } catch {
            fatalError("Could not validate the provided services configuration. Please check the contents are valid.")
        }

        self.servicesInfo = servicesInfo
        self.options = options

        logger.hasDebugLoggingEnabled = self.options?.debugLoggingEnabled ?? false

        if !LocalStorage.migrated {
            logger.debug("Checking if there is legacy data that needs to be migrated.")
            let migration = LocalStorageMigration()

            if migration.hasLegacyData {
                migration.migrate()
                logger.info("Legacy data found and migrated to the new storage format.")
            }

            LocalStorage.migrated = true
        }

        // The default value of the deferred link depends on whether Notificare has a registered device.
        // Having a registered device means the app ran at least once and we should stop checking for
        // deferred links.
        if LocalStorage.deferredLinkChecked == nil {
            LocalStorage.deferredLinkChecked = LocalStorage.device != nil
        }

        logger.debug("Configuring network services.")
        configureReachability(servicesInfo: servicesInfo)

        if options.swizzlingEnabled {
            var swizzleApns = false

            // Check if the Push module is loaded.
            if NotificareInternals.Module.push.isAvailable {
                swizzleApns = true
            }

            NotificareSwizzler.setup(withRemoteNotifications: swizzleApns)
        } else {
            logger.warning("""
            Automatic App Delegate Proxy is not enabled. \
            You will need to forward UIAppDelegate events to Notificare manually. \
            Please check the documentation for which events to forward.
            """)
        }

        logger.debug("Configuring available modules.")
        database.configure()

        NotificareInternals.Module.allCases.forEach { module in
            if let instance = module.klass?.instance {
                logger.debug("Configuring module: \(module)")
                instance.configure()
            }
        }

        logger.debug("Notificare configured all services.")
        state = .configured

        if !servicesInfo.hasDefaultHosts {
            logger.info("Notificare configured with customized hosts.")
            logger.debug("REST API host: \(servicesInfo.hosts.restApi)")
            logger.debug("AppLinks host: \(servicesInfo.hosts.appLinks)")
            logger.debug("Short Links host: \(servicesInfo.hosts.shortLinks)")
        }
    }

    /// Launches the Notificare SDK, and all the additional available modules, preparing them for use, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the launch operation.
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

    /// Launches the Notificare SDK, and all the additional available modules, preparing them for use.
    public func launch() async throws {
        if state == .none {
            logger.debug("Notificare wasn't configured. Configuring before launching.")
            configure()
        }

        if state > .configured {
            logger.warning("Notificare has already been launched. Skipping...")
            return
        }

        logger.info("Launching Notificare.")
        state = .launching

        do {
            // Start listening for reachability events.
            logger.debug("Start listening to reachability events.")
            try reachability!.startNotifier()
        } catch {
            logger.error("Failed to start listening to reachability events.", error: error)
            fatalError("Failed to start listening to reachability events.")
        }

        do {
            let application = try await fetchApplication(saveToLocalStorage: false)
            let storedApplication = LocalStorage.application

            if let storedApplication, storedApplication.id != application.id {
                logger.warning("Incorrect application keys detected. Resetting Notificare to a clean state.")

                for module in NotificareInternals.Module.allCases {
                    if let instance = module.klass?.instance {
                        logger.debug("Resetting module: \(module)")

                        do {
                            try await instance.clearStorage()
                        } catch {
                            logger.debug("Failed to reset '\(module)'.", error: error)
                            throw error
                        }
                    }
                }

                try database.clear()
                LocalStorage.clear()
            }

            self.application = application

            // Loop all possible modules and launch the available ones.
            for module in NotificareInternals.Module.allCases {
                if let instance = module.klass?.instance {
                    logger.debug("Launching module: \(module)")

                    do {
                        try await instance.launch()
                    } catch {
                        logger.debug("Failed to launch '\(module)'.", error: error)
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
            logger.error("Failed to launch Notificare.", error: error)
            state = .configured
            throw error
        }

        Task {
            // Loop all possible modules and post-launch the available ones.
            for module in NotificareInternals.Module.allCases {
                if let instance = module.klass?.instance {
                    do {
                        logger.debug("Post-launching module: \(module)")
                        try await instance.postLaunch()
                    } catch {
                        logger.error("Failed to post-launch '\(module)'.", error: error)
                    }
                }
            }
        }
    }

    /// Unlaunches the Notificare SDK, with a callback.
    ///
    /// This method shuts down the SDK, removing all data, both locally and remotely in
    /// the servers. It destroys all the device's data permanently.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the unlaunch operation.
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

    /// Unlaunches the Notificare SDK.
    ///
    /// This method shuts down the SDK, removing all data, both locally and remotely in
    /// the servers. It destroys all the device's data permanently.
    public func unlaunch() async throws {
        guard isReady else {
            logger.warning("Cannot un-launch Notificare before it has been launched.")
            return
        }

        logger.info("Un-launching Notificare.")

        // Loop all possible modules and un-launch the available ones.
        for module in NotificareInternals.Module.allCases.reversed() {
            if let instance = module.klass?.instance {
                logger.debug("Un-launching module: \(module)")

                do {
                    try await instance.unlaunch()
                } catch {
                    logger.debug("Failed to un-launch '\(module)'.", error: error)
                    throw error
                }
            }
        }

        logger.debug("Removing device.")
        try await self.deviceImplementation().delete()

        logger.info("Un-launched Notificare.")
        self.state = .configured

        DispatchQueue.main.async {
            self.delegate?.notificareDidUnlaunch(self)
        }
    }

    /// Fetches the application metadata, with a callback.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the fetch application operation.
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

    /// Fetches the application metadata.
    ///
    /// - Returns: The ``NotificareApplication`` metadata.
    public func fetchApplication() async throws -> NotificareApplication {
        return try await fetchApplication(saveToLocalStorage: true)
    }

    /// Fetches a ``NotificareDynamicLink`` from a String URL, with a callback.
    ///
    /// - Parameters:
    ///   - link: The string URL to fetch the dynamic link from.
    ///   - completion: A callback tha will be invoked with the result of the fetch dynamic link operation.
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

    /// Fetches a ``NotificareDynamicLink`` from a String URL.
    ///
    /// - Parameters:
    ///   - link: The string URL to fetch the dynamic link from.
    ///
    /// - Returns: The ``NotificareDynamicLink`` object.
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

    /// Fetches a ``NotificareNotification`` by its ID, with a callback.
    ///
    /// - Parameters:
    ///   - id: The ID of the notification to fetch.
    ///   - completion: A callback that will be invoked with the result of the fetch notification operation.
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

    /// Fetches a ``NotificareNotification`` by its ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the notification to fetch.
    ///
    /// - Returns: The ``NotificareNotification` object associated with the provided ID.
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

    /// Sends a reply to a notification action, with a callback.
    ///
    /// This method sends a reply to the specified ``NotificareNotification`` and ``NotificareNotification.Action``,
    /// optionally including a message and media.
    ///
    /// - Parameters:
    ///   - notification: The notification to reply to.
    ///   - action: The action associated with the reply.
    ///   - message: An optional message to include with the reply.
    ///   - media: An optional media file to attach with the reply.
    ///   - mimeType: The MIME type of the media.
    ///   - completion: A callback that will be invoked with the result of the create notification reply operation
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

    /// Sends a reply to a notification action.
    /// 
    /// This method sends a reply to the specified ``NotificareNotification`` and ``NotificareNotification.Action``,
    /// optionally including a message and media.
    ///
    /// - Parameters:
    ///   - notification: The notification to reply to.
    ///   - action: The action associated with the reply.
    ///   - message: An optional message to include with the reply.
    ///   - media: An optional media file to attach with the reply.
    ///   - mimeType: The MIME type of the media.
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

    /// Calls a notification reply webhook, with a callback.
    ///
    /// This method sends data to the specified webhook ``URL``.
    ///
    /// - Parameters:
    ///   - url: The webhook URL.
    ///   - data: The data to send in the request.
    ///   - completion: A callback that will be invoked with the result of the call notificatio reply webhook operation.
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

    /// Calls a notification reply webhook.
    /// 
    /// This method sends data to the specified webhook ``URL``.
    /// 
    /// - Parameters:
    ///   - url: The webhook URL.
    ///   - data: The data to send in the request.
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

    /// Uploads an asset for a notification reply, with a callback.
    ///
    /// This method uploads a data object as part of a notification reply.
    ///
    /// - Parameters:
    ///   - data: The ``Data`` object containing the asset data.
    ///   - contentType: The MIME type of the asset.
    ///   - completion: A callback that will be invoked with the result of the upload notification reply operation.
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

    /// Uploads an asset for a notification reply.
    /// 
    /// This method uploads a data object as part of a notification reply.
    /// 
    /// - Parameters:
    ///   - data: The ``Data`` object containing the asset data.
    ///   - contentType: The MIME type of the asset.
    ///
    /// - Returns: The URL of the uploaded asset.
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

    /// Removes a notification from the Notification Center.
    ///
    /// - Parameters:
    ///   - notification: The ``NotificareNotification`` to remove.
    public func removeNotificationFromNotificationCenter(_ notification: NotificareNotification) {
        removeNotificationFromNotificationCenter(notification.id)
    }

    /// Removes a notification from the Notification Center, by its ID.
    ///
    /// - Parameters:
    ///   - notificationId: The ID of the notification to remove.
    public func removeNotificationFromNotificationCenter(_ notificationId: String) {
        logger.debug("Removing notification '\(notificationId)' from the notification center.")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationId])
    }

    /// Handles an URL by validating it and registering the current device as a test device for Notificare Services.
    ///
    /// - Parameters:
    ///   - url: The URL containing the test device nonce.
    ///
    /// - Returns: `true` if the device registration process was initiated, or `false` if no valid nonce was found in the URL.
    public func handleTestDeviceUrl(_ url: URL) -> Bool {
        guard let nonce = parseTestDeviceNonce(url: url) else {
            return false
        }

        Task {
            do {
                try await deviceImplementation().registerTestDevice(nonce: nonce)
                logger.info("Device registered for testing.")
            } catch {
                logger.error("Failed to register the device for testing.", error: error)
            }
        }

        return true
    }

    /// Handles an URL for dynamic links.
    ///
    /// - Parameters:
    ///   - url: The URL to handle.
    ///
    /// - Returns: `true` if the URL was handled, `false` otherwise.
    public func handleDynamicLinkUrl(_ url: URL) -> Bool {
        guard let url = parseDynamicLink(url: url) else {
            return false
        }

        Task {
            do {
                logger.debug("Handling a dynamic link.")
                let link = try await fetchDynamicLink(url.absoluteString)

                guard let targetUrl = URL(string: link.target) else {
                    logger.warning("Failed to parse the dynamic link target url.")
                    return
                }

                DispatchQueue.main.async {
                    UIApplication.shared.open(targetUrl, options: [:]) { opened in
                        if !opened {
                            logger.warning("The dynamic link's target was not handled by the application.")
                        }
                    }
                }
            } catch {
                logger.warning("Failed to fetch the dynamic link.", error: error)
            }
        }

        return true
    }

    /// Evaluates the deferred link, opening the resolved deferred link.
    ///
    /// It should be called only after verifying deferred link eligibility with `canEvaluateDeferredLink`.
    ///
    /// - Returns: `true` if the deferred link was successfully evaluated, `false` otherwise.
    @MainActor
    public func evaluateDeferredLink() async throws -> Bool {
        guard LocalStorage.deferredLinkChecked == false else {
            logger.debug("Deferred link already evaluated.")
            return false
        }

        defer {
            LocalStorage.deferredLinkChecked = true
        }

        guard UIPasteboard.general.hasURLs else {
            logger.debug("Detected URLs in the clipboard.")
            return false
        }

        guard let deferredUrl = UIPasteboard.general.url else {
            logger.warning("Detected URLs in the clipboard but the user denied access.")
            return false
        }

        let dynamicLink = try await fetchDynamicLink(deferredUrl.absoluteString)

        guard let url = URL(string: dynamicLink.target) else {
            logger.warning("Failed to parse the dynamic link target url.")
            return false
        }

        guard UIApplication.shared.canOpenURL(url) else {
            logger.warning("Cannot open a deep link that's not supported by the application.")
            return false
        }

        defer {
            UIPasteboard.general.items = []
        }

        return await UIApplication.shared.open(url)
    }

    /// Evaluates the deferred link, opening the resolved deferred link, with a callback.
    ///
    /// It should be called only after verifying deferred link eligibility with `canEvaluateDeferredLink()`.
    ///
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the evaluate deferred link operation.
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
                logger.debug("Notificare is reachable.")
            }

            reachability?.whenUnreachable = { _ in
                logger.debug("Notificare is unreachable.")
            }
        } catch {
            fatalError("Failed to configure the reachability module: \(error.localizedDescription)")
        }
    }

    private func printLaunchSummary(application: NotificareApplication) {
        let enabledServices = application.services.filter(\.value).map(\.key)
        let enabledModules = ModuleUtils.getEnabledPeerModules()

        logger.info("Notificare is ready to use for application.")
        logger.debug("/==================================================================================/")
        logger.debug("App name: \(application.name)")
        logger.debug("App ID: \(application.id)")
        logger.debug("App services: \(enabledServices.joined(separator: ", "))")
        logger.debug("/==================================================================================/")
        logger.debug("SDK version: \(Notificare.SDK_VERSION)")
        logger.debug("SDK modules: \(enabledModules.joined(separator: ", "))")
        logger.debug("/==================================================================================/")
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
            logger.warning("Unable to parse dynamic link. Notificare services have not been configured.")
            return nil
        }

        guard host.matches("^([a-z0-9-])+\\.\\Q\(servicesInfo.hosts.shortLinks)\\E$".toRegex()) else {
            logger.debug("Domain pattern wasn't a match.")
            return nil
        }

        guard url.pathComponents.count == 2 else {
            logger.debug("Path components length wasn't a match.")
            return nil
        }

        let code = url.pathComponents[1]
        guard code.matches("^[a-zA-Z0-9_-]+$".toRegex()) else {
            logger.debug("First path component value wasn't a match.")
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
