//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

public class NotificareAutoConfig: NSObject {
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

        guard Notificare.shared.state == .none else {
            NotificareLogger.debug("Notificare has already been configured. Skipping automatic configuration...")
            return
        }

        var autoConfig = true
        if let path = Bundle.main.path(forResource: NotificareOptions.fileName, ofType: NotificareOptions.fileExtension),
           let options = NotificareOptions(contentsOfFile: path)
        {
            autoConfig = options.autoConfig
        }

        guard autoConfig else {
            NotificareLogger.debug("Notificare auto config is disabled. Skipping automatic configuration...")
            return
        }

        Notificare.shared.configure()
    }
}
