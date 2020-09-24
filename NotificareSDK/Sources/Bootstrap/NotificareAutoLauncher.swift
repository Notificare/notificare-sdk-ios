//
// Created by Helder Pinhal on 24/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public class NotificareAutoLauncher: NSObject {

    @objc
    public static func setup() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(didFinishLaunching(_:)),
                name: UIApplication.didFinishLaunchingNotification,
                object: nil)
    }

    @objc
    public static func didFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.didFinishLaunchingNotification,
                object: nil)

        Notificare.shared.logger.debug("Auto launching Notificare.")
        self.autoLaunch()
    }

    private static func autoLaunch() {
        guard Notificare.shared.state == .none else {
            Notificare.shared.logger.warning("Cannot auto launch. Notificare has already been configured.")
            return
        }

        guard let configuration = NotificareUtils.getConfiguration(),
              let applicationKey = configuration.production ? configuration.productionApplicationKey : configuration.developmentApplicationKey,
              let applicationSecret = configuration.production ? configuration.productionApplicationSecret : configuration.developmentApplicationSecret else {

            return
        }

        var environment: NotificareEnvironment = .production
        if let environmentStr = configuration.environment?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
           let parsedEnvironment = NotificareEnvironment(rawValue: environmentStr) {
            environment = parsedEnvironment
        }

        Notificare.shared.configure(
                applicationKey: applicationKey,
                applicationSecret: applicationSecret,
                withEnvironment: environment)

        guard configuration.autoLaunch else {
            Notificare.shared.logger.debug("Auto launch is not enabled. Skipping...")
            return
        }

        Notificare.shared.launch()
    }
}
