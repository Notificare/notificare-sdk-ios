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

    public var delegate: NotificareDelegate?

    private init() {}

    public func configure(applicationKey: String, applicationSecret: String, withEnvironment environment: NotificareEnvironment = .production) {
        guard state == .none else {
            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
            return
        }

        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.environment = environment

        setupNetworking()
        loadAvailableModules()

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

        // TODO: configure all the modules / managers
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

        NotificareLaunchManager.shared.launch { result in
            switch result {
            case let .success(applicationInfo):
                self.applicationInfo = applicationInfo
                self.state = .launched

                Notificare.shared.logger.debug("/==================================================================================/")
                Notificare.shared.logger.debug("Notificare SDK is ready to use for application")
                Notificare.shared.logger.debug("App name: \(applicationInfo.name)")
                Notificare.shared.logger.debug("App ID: \(applicationInfo.id)")

                let enabledServices = applicationInfo.services.filter { $0.value }.map { $0.key }
                Notificare.shared.logger.debug("App services: \(enabledServices.joined(separator: ", "))")
                Notificare.shared.logger.debug("/==================================================================================/")
                Notificare.shared.logger.debug("SDK version: \(NotificareConstants.sdkVersion)")
                Notificare.shared.logger.debug("/==================================================================================/")

                self.eventLogger.launch()

                // All good. Notify delegate.
                self.state = .ready
                self.delegate?.notificare(self, onReady: applicationInfo)
            case let .failure(error):
                Notificare.shared.logger.error("Failed to load the application info: \(error)")

                // Revert back to previous state.
                self.state = .configured
            }
        }
    }

    public func unLaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
        state = .configured
    }

    private func setupNetworking() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCredentialStorage = nil

        pushApi = NotificarePushApi(
            applicationKey: applicationKey!,
            applicationSecret: applicationSecret!,
            session: URLSession(configuration: sessionConfiguration)
        )
    }

    private func loadAvailableModules() {
        let factory = NotificareModuleFactory()
        pushManager = factory.createPushManager()
        locationManager = factory.createLocationManager()

        NotificareUtils.logLoadedModules()
    }

    private func clearNetworking() {
        pushApi = nil
    }

    private func clearLoadedModules() {
        pushManager = nil
        locationManager = nil
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
