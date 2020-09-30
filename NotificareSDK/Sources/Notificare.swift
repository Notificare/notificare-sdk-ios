//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public class Notificare {
    public static let shared = Notificare()

    public private(set) var logger = NotificareLogger()
    public private(set) var eventLogger = NotificareEventLogger()
    public private(set) var pushManager: NotificarePushManager?
    public private(set) var locationManager: NotificareLocationManager?

    internal let coreDataManager = NotificareCoreDataManager()

    internal private(set) var environment: NotificareEnvironment = .production
    internal private(set) var applicationKey: String?
    internal private(set) var applicationSecret: String?
    internal private(set) var pushApi: NotificarePushApi?

    internal private(set) var state: State = .none
    internal private(set) var applicationInfo: NotificareApplicationInfo?

    public weak var delegate: NotificareDelegate?

    private init() {}

    public func configure(applicationKey: String, applicationSecret: String, withEnvironment environment: NotificareEnvironment = .production) {
        guard state == .none else {
            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
            return
        }

        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.environment = environment

        Notificare.shared.logger.debug("Configuring network services.")
        configureNetworking(applicationKey: applicationKey, applicationSecret: applicationSecret, environment: environment)

        Notificare.shared.logger.debug("Loading available modules.")
        createAvailableModules()

        let configuration = NotificareUtils.getConfiguration()
        if configuration?.swizzlingEnabled ?? true {
            NotificareSwizzler.setup(withRemoteNotifications: pushManager != nil)
        } else {
            Notificare.shared.logger.warning("""
            Automatic App Delegate Proxy is not enabled. \
            You will need to forward UIAppDelegate events to Notificare manually. \
            Please check the documentation for which events to forward.
            """)
        }

        Notificare.shared.logger.debug("Configuring available modules.")
        coreDataManager.configure()
        eventLogger.configure()
        NotificareDeviceManager.shared.configure()
        pushManager?.configure()

        Notificare.shared.logger.debug("Notificare configured for '\(environment)' services.")
        state = .configured
    }

    public func launch() {
        if state == .none {
            Notificare.shared.logger.warning("Notificare.initialize() has never been called. Cannot launch.")
            return
        }

        if state == .launching {
            Notificare.shared.logger.warning("Notificare has already been launched. Skipping...")
            return
        }

        Notificare.shared.logger.info("Launching Notificare.")
        state = .launching

        // Setup local database stores.
        coreDataManager.launch { result in
            switch result {
            case .success:
                // Fetch the application info.
                self.pushApi!.getApplicationInfo { result in
                    switch result {
                    case let .success(applicationInfo):
                        // Launch the device manager: registration.
                        NotificareDeviceManager.shared.launch { _ in
                            // Ignore the error if device registration fails.

                            // Launch the event logger
                            self.eventLogger.launch()

                            self.launchResult(.success(applicationInfo))
                        }
                    case let .failure(error):
                        Notificare.shared.logger.error("Failed to load the application info: \(error)")
                        self.launchResult(.failure(error))
                    }
                }
            case let .failure(error):
                Notificare.shared.logger.error("Failed to load local database: \(error.localizedDescription)")
                fatalError("Failed to load local database: \(error.localizedDescription)")
            }
        }
    }

    public func unlaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
        state = .configured
    }

    private func configureNetworking(applicationKey: String, applicationSecret: String, environment: NotificareEnvironment) {
        pushApi = NotificarePushApi(
            applicationKey: applicationKey,
            applicationSecret: applicationSecret,
            environment: environment
        )
    }

    private func createAvailableModules() {
        let factory = NotificareModuleFactory()
        pushManager = factory.createPushManager()
        locationManager = factory.createLocationManager()
    }

    private func launchResult(_ result: Result<NotificareApplicationInfo, Error>) {
        switch result {
        case let .success(applicationInfo):
            self.applicationInfo = applicationInfo
            state = .ready

            let enabledServices = applicationInfo.services.filter { $0.value }.map(\.key)
            let enabledModules = NotificareUtils.getLoadedModules()

            Notificare.shared.logger.debug("/==================================================================================/")
            Notificare.shared.logger.debug("Notificare SDK is ready to use for application")
            Notificare.shared.logger.debug("App name: \(applicationInfo.name)")
            Notificare.shared.logger.debug("App ID: \(applicationInfo.id)")
            Notificare.shared.logger.debug("App services: \(enabledServices.joined(separator: ", "))")
            Notificare.shared.logger.debug("/==================================================================================/")
            Notificare.shared.logger.debug("SDK version: \(NotificareConstants.sdkVersion)")
            Notificare.shared.logger.debug("SDK modules: \(enabledModules.joined(separator: ", "))")
            Notificare.shared.logger.debug("/==================================================================================/")

            // We're done launching. Notify the delegate.
            delegate?.notificare(self, onReady: applicationInfo)
        case .failure:
            Notificare.shared.logger.error("Failed to launch Notificare.")
            state = .configured
        }
    }

    internal enum State: Int {
        case none
        case configured
        case launching
        case launched
        case ready
    }
}

// MARK: - Notificare.State Comparable

extension Notificare.State: Comparable {
    public static func < (lhs: Notificare.State, rhs: Notificare.State) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static func <= (lhs: Notificare.State, rhs: Notificare.State) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }

    public static func >= (lhs: Notificare.State, rhs: Notificare.State) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }

    public static func > (lhs: Notificare.State, rhs: Notificare.State) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
