//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareCore
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

    @objc public static func didFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )

        NotificareLogger.debug("Auto launching Notificare.")
        autoLaunch(options: notification.userInfo as? [UIApplication.LaunchOptionsKey: Any])
    }

    private static func autoLaunch(options: [UIApplication.LaunchOptionsKey: Any]?) {
        guard Notificare.shared.state == .none else {
            NotificareLogger.debug("Notificare has already been configured. Skipping automatic configuration...")
            return
        }

        guard let configuration = NotificareUtils.getConfiguration(),
              let applicationKey = configuration.production ? configuration.productionApplicationKey : configuration.developmentApplicationKey,
              let applicationSecret = configuration.production ? configuration.productionApplicationSecret : configuration.developmentApplicationSecret,
              !applicationKey.isEmpty, !applicationSecret.isEmpty
        else {
            NotificareLogger.debug("Notificare.plist doesn't contain a valid key set. Skipping...")
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

        Notificare.shared.launchOptions = options

        guard configuration.autoLaunch else {
            NotificareLogger.debug("Auto launch is not enabled. Skipping...")
            return
        }

        Notificare.shared.launch()
    }
}
