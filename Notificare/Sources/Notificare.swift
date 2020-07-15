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

    internal private(set) var applicationKey: String? = nil
    internal private(set) var applicationSecret: String? = nil

    public var isInitialized: Bool {
        applicationKey != nil && applicationSecret != nil
    }
    public private(set) var isLaunched: Bool = false
    public private(set) var isReady: Bool = false


    private init() {
    }


    public func initialize(applicationKey: String, applicationSecret: String) {
        guard !isInitialized else {
            Notificare.shared.logger.warning("Notificare has already been initialized. Skipping...")
            return
        }

        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }

    public func launch() {
        guard isInitialized else {
            Notificare.shared.logger.warning("Notificare.initialize() has never been called. Cannot launch.")
            return
        }

        guard !isLaunched else {
            Notificare.shared.logger.warning("Notificare has already been launched. Skipping...")
            return
        }

        Notificare.shared.logger.info("Launching Notificare.")
        isLaunched = true

        self.loadAvailableModules()
    }

    public func unLaunch() {
        Notificare.shared.logger.info("Un-launching Notificare.")
        clearLoadedModules()
    }


    internal func autoLaunch() {
        let configuration = NotificareUtils.getConfiguration()

        guard configuration.autoLaunch else {
            Notificare.shared.logger.info("Auto launch is not enabled. Skipping...")
            return
        }

        let applicationKey = configuration.production ? configuration.productionApplicationKey : configuration.developmentApplicationKey
        let applicationSecret = configuration.production ? configuration.productionApplicationSecret : configuration.developmentApplicationSecret

        Notificare.shared.initialize(applicationKey: applicationKey!, applicationSecret: applicationSecret!)
        Notificare.shared.launch()
    }

    private func loadAvailableModules() {
        let factory = NotificareModuleFactory()
        self.pushManager = factory.createPushManager()
        self.locationManager = factory.createLocationManager()

        NotificareUtils.logLoadedModules()
    }

    private func clearLoadedModules() {
        self.pushManager = nil
        self.locationManager = nil
    }
}
