//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareCore
import UIKit

public typealias NotificareCallback<T> = (Result<T, NotificareError>) -> Void

public class Notificare {
    public static let shared = Notificare()

    // Internal modules
    internal let crashReporter = NotificareCrashReporter()
    internal let sessionManager = NotificareSessionManager()
    internal let database = NotificareDatabase()
    internal private(set) var reachability: NotificareReachability?
    public private(set) var pushApi: NotificarePushApi?

    // Consumer modules
    public let eventsManager = NotificareEventsModule()
    public let deviceManager = NotificareDeviceManager()

    // Configuration variables
    internal private(set) var applicationKey: String?
    internal private(set) var applicationSecret: String?
    internal private(set) var services: NotificareServices = .production

    // Launch / application state
    internal private(set) var state: NotificareLaunchState = .none
    public private(set) var application: NotificareApplication?
    public var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    public weak var delegate: NotificareDelegate?

    private init() {}

    // MARK: - Public API

    public var isConfigured: Bool {
        state >= .configured
    }

    public var isReady: Bool {
        state == .ready
    }

    public func configure(applicationKey: String, applicationSecret: String) {
        configure(applicationKey: applicationKey, applicationSecret: applicationSecret, services: .production)
    }

    public func launch() {
        if state == .none {
            NotificareLogger.warning("Notificare.configure() has never been called. Cannot launch.")
            return
        }

        if state > .configured {
            NotificareLogger.warning("Notificare has already been launched. Skipping...")
            return
        }

        NotificareLogger.info("Launching Notificare.")
        state = .launching

        // Setup local database stores.
        database.launch { result in
            switch result {
            case .success:
                self.sessionManager.launch()

                do {
                    // Start listening for reachability events.
                    NotificareLogger.debug("Start listening to reachability events.")
                    try self.reachability!.startNotifier()
                } catch {
                    NotificareLogger.error("Failed to start listening to reachability events: \(error)")
                    fatalError("Failed to start listening to reachability events: \(error)")
                }

                // Fetch the application info.
                self.pushApi!.getApplicationInfo { result in
                    switch result {
                    case let .success(application):
                        self.application = application

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
            case let .failure(error):
                NotificareLogger.error("Failed to load local database: \(error.localizedDescription)")
                fatalError("Failed to load local database: \(error.localizedDescription)")
            }
        }
    }

    public func unlaunch() {
        NotificareLogger.info("Un-launching Notificare.")
        state = .configured
    }

    public func fetchDynamicLink(_ link: String, _ completion: @escaping NotificareCallback<NotificareDynamicLink>) {
        guard isConfigured, let api = pushApi else {
            completion(.failure(.notReady))
            return
        }

        api.getDynamicLink(link, completion)
    }

    // MARK: - Private API

    internal func configure(applicationKey: String, applicationSecret: String, services: NotificareServices) {
        guard state == .none else {
            NotificareLogger.warning("Notificare has already been configured. Skipping...")
            return
        }

        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.services = services

        NotificareLogger.debug("Configuring network services.")
        configureNetworking(applicationKey: applicationKey, applicationSecret: applicationSecret, services: services)

        let configuration = NotificareUtils.getConfiguration()
        if configuration?.swizzlingEnabled ?? true {
            // NotificareSwizzler.setup(withRemoteNotifications: pushManager != nil)
            NotificareSwizzler.setup(withRemoteNotifications: false)
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
                cls.configure(applicationKey: applicationKey, applicationSecret: applicationSecret)
            }
        }

        NotificareLogger.debug("Notificare configured for '\(services)' services.")
        state = .configured
    }

    private func configureNetworking(applicationKey: String, applicationSecret: String, services: NotificareServices) {
        do {
            reachability = try NotificareReachability(hostname: services.pushHost.host!)

            reachability?.whenReachable = { _ in
                NotificareLogger.debug("Notificare is reachable.")
            }

            reachability?.whenUnreachable = { _ in
                NotificareLogger.debug("Notificare is unreachable.")
            }
        } catch {
            fatalError("Failed to configure the reachability module: \(error.localizedDescription)")
        }

        pushApi = NotificarePushApi(
            applicationKey: applicationKey,
            applicationSecret: applicationSecret,
            services: services
        )
    }

    private func launchResult(_ result: Result<NotificareApplication, Error>) {
        switch result {
        case let .success(application):
            self.application = application
            state = .ready

            let enabledServices = application.services.filter { $0.value }.map(\.key)
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
}
