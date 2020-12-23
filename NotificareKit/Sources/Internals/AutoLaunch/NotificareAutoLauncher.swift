//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public class NotificareAutoLauncher: NSObject {
    @objc public static func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishLaunching(_:)),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc public static func didFinishLaunching(_: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )

        Notificare.shared.logger.debug("Auto launching Notificare.")
        autoLaunch()
    }

    private static func autoLaunch() {
        guard Notificare.shared.state == .none else {
            Notificare.shared.logger.debug("Notificare has already been configured. Skipping automatic configuration...")
            return
        }

        guard let configuration = NotificareUtils.getConfiguration(),
              let applicationKey = configuration.production ? configuration.productionApplicationKey : configuration.developmentApplicationKey,
              let applicationSecret = configuration.production ? configuration.productionApplicationSecret : configuration.developmentApplicationSecret,
              !applicationKey.isEmpty, !applicationSecret.isEmpty
        else {
            Notificare.shared.logger.debug("Notificare.plist doesn't contain a valid key set. Skipping...")
            return
        }

        var services: NotificareServices = .production
        if let str = configuration.services?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
           let parsed = NotificareServices(rawValue: str)
        {
            services = parsed
        }

        Notificare.shared.configure(
            applicationKey: applicationKey,
            applicationSecret: applicationSecret,
            services: services
        )

        guard configuration.autoLaunch else {
            Notificare.shared.logger.debug("Auto launch is not enabled. Skipping...")
            return
        }

        Notificare.shared.launch()
    }
}
