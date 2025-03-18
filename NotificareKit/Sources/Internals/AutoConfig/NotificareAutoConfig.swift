//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

@MainActor
public class NotificareAutoConfig: NSObject {
    @objc public static func setup() {
        addApplicationLaunchListener()
    }

    private static func addApplicationLaunchListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    private static func removeApplicationLaunchListener() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc private static func didFinishLaunching() {
        removeApplicationLaunchListener()
        autoConfigure()
    }

    private static func autoConfigure() {
        guard shouldAutoConfigure() else {
            logger.debug("Skipping automatic configuration...")
            return
        }

        Notificare.shared.configure()
    }

    private static func shouldAutoConfigure() -> Bool {
        guard Notificare.shared.state == .none else {
            logger.debug("Notificare has already been configured.")
            return false
        }

        guard let options = loadOptions() else {
            return true
        }

        if !options.autoConfig {
            logger.debug("Notificare auto config is disabled.")
        }

        return options.autoConfig
    }

    private static func loadOptions() -> NotificareOptions? {
        guard let path = Bundle.main.path(
            forResource: NotificareOptions.fileName,
            ofType: NotificareOptions.fileExtension
        ) else { return nil }

        return NotificareOptions(contentsOfFile: path)
    }
}
