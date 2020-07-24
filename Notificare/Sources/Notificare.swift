//
//  Notificare.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public class Notificare {

    public static let shared = Notificare()

    public var logger = NotificareLogger()
    public private(set) var pushManager: NotificarePushManager? = nil
    public private(set) var locationManager: NotificareLocationManager? = nil

    internal private(set) var environment: NotificareEnvironment = .production
    internal private(set) var applicationKey: String? = nil
    internal private(set) var applicationSecret: String? = nil
    internal private(set) var pushApi: NotificarePushApi? = nil

    private var state: State = .none


    private init() {
    }


    public func configure(applicationKey: String, applicationSecret: String, withEnvironment environment: NotificareEnvironment = .production) {
        guard state == .none else {
            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
            return
        }

        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.environment = environment

        Notificare.shared.logger.debug("Notificare configured for '\(environment)' services.")
        self.state = .configured
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

        self.setupNetworking()
        self.loadAvailableModules()

        self.pushApi!.getApplicationInfo { result in
            switch result {
            case .success(let applicationInfo):
                Notificare.shared.logger.info("Notificare is ready.")
                Notificare.shared.logger.debug("\(applicationInfo)")

                // All good. Notify delegate.
                self.state = .ready
                // self.delegate?.ready()
            case .failure(let error):
                Notificare.shared.logger.error("Failed to load the application info: \(error)")

                // Revert back to previous state.
                self.state = .configured
            }
        }
    }

    public func unLaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
        clearNetworking()
        clearLoadedModules()
        state = .none
    }


    internal func autoLaunch() {
        let configuration = NotificareUtils.getConfiguration()

        guard configuration.autoLaunch else {
            Notificare.shared.logger.info("Auto launch is not enabled. Skipping...")
            return
        }

        let applicationKey = configuration.production ? configuration.productionApplicationKey : configuration.developmentApplicationKey
        let applicationSecret = configuration.production ? configuration.productionApplicationSecret : configuration.developmentApplicationSecret

        var environment: NotificareEnvironment = .production
        if let environmentStr = configuration.environment?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
           let parsedEnvironment = NotificareEnvironment(rawValue: environmentStr) {
            environment = parsedEnvironment
        }

        Notificare.shared.configure(applicationKey: applicationKey!, applicationSecret: applicationSecret!, withEnvironment: environment)
        Notificare.shared.launch()
    }

    private func setupNetworking() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCredentialStorage = nil

        self.pushApi = NotificarePushApi(
                applicationKey: self.applicationKey!,
                applicationSecret: self.applicationSecret!,
                session: URLSession(configuration: sessionConfiguration)
        )
    }

    private func loadAvailableModules() {
        let factory = NotificareModuleFactory()
        self.pushManager = factory.createPushManager()
        self.locationManager = factory.createLocationManager()

        NotificareUtils.logLoadedModules()
    }

    private func clearNetworking() {
        self.pushApi = nil
    }

    private func clearLoadedModules() {
        self.pushManager = nil
        self.locationManager = nil
    }


    private enum State {
        case none
        case configured
        case launching
        case launched
        case ready
    }
}
