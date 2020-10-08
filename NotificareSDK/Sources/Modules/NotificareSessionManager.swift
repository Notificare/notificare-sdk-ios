//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

class NotificareSessionManager {
    internal private(set) var currentSession: String?

    func configure() {
        // Ensure there is no previous session
        NotificareUserDefaults.sessionDate = nil

        // Listen to 'application did become active'
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to 'application will resign active'
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    func launch() {
        // Create a new session
        currentSession = UUID().uuidString
    }

    @objc private func applicationDidBecomeActive() {
        Notificare.shared.logger.info("Application entering foreground.")

        guard NotificareUserDefaults.sessionDate == nil,
            UIApplication.shared.applicationState == .active
        else {
            return
        }

        NotificareUserDefaults.sessionDate = Date()

        guard let session = currentSession else {
            Notificare.shared.logger.warning("There is no current session.")
            return
        }

        Notificare.shared.logger.info("Session started with ID: \(session)")
        Notificare.shared.eventsManager.logApplicationOpen()
    }

    @objc private func applicationWillResignActive() {
        Notificare.shared.logger.info("Application entering background.")

        guard UIApplication.shared.applicationState == .active else {
            Notificare.shared.logger.debug("Application is not active. Skipping...")
            return
        }

        guard let session = currentSession else {
            Notificare.shared.logger.debug("No session found. Skipping...")
            return
        }

        guard let sessionDate = NotificareUserDefaults.sessionDate else {
            Notificare.shared.logger.debug("No session start date found. Skipping...")
            return
        }

        let sessionDiff = sessionDate.timeIntervalSinceNow
        let nowDiff = Date().timeIntervalSinceNow

        guard nowDiff > sessionDiff else {
            Notificare.shared.logger.debug("Session start date in the future. Skipping...")
            return
        }

        let diff = nowDiff - sessionDiff
        guard diff > 1 else {
            Notificare.shared.logger.debug("Session length smaller than a second. Skipping...")
            return
        }

        Notificare.shared.logger.info("Application closed event registered for session '\(session)' with a length of \(diff) seconds.")
        Notificare.shared.eventsManager.logApplicationClose(length: diff)

        // Reset the session.
        NotificareUserDefaults.sessionDate = nil
        currentSession = UUID().uuidString
    }
}
