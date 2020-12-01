//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

class NotificareSessionManager {
    internal private(set) var sessionId: String?
    private var sessionStart: Date?
    private var sessionEnd: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var workItem: DispatchWorkItem?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        return formatter
    }()

    func configure() {
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

    func launch() {}

    @objc private func applicationDidBecomeActive() {
        guard UIApplication.shared.applicationState == .active else {
            return
        }

        // Cancel any session timeout.
        workItem?.cancel()
        UIApplication.shared.endBackgroundTask(backgroundTask)

        guard sessionStart == nil else {
            Notificare.shared.logger.debug("Resuming previous session.")
            return
        }

        let sessionId = UUID().uuidString.lowercased()
        let sessionStart = Date()

        self.sessionId = sessionId
        self.sessionStart = sessionStart
        sessionEnd = nil

        Notificare.shared.logger.debug("Session '\(sessionId)' started at \(dateFormatter.string(from: sessionStart))")
        Notificare.shared.eventsManager.logApplicationOpen()
    }

    @objc private func applicationWillResignActive() {
        guard UIApplication.shared.applicationState == .active else {
            Notificare.shared.logger.debug("Application is not active. Skipping...")
            return
        }

        guard let sessionId = sessionId else {
            Notificare.shared.logger.debug("No session found. Skipping...")
            return
        }

        let sessionEnd = Date()
        self.sessionEnd = sessionEnd

        Notificare.shared.logger.debug("Session '\(sessionId)' stopped at \(dateFormatter.string(from: sessionEnd))")

        // Wait a few seconds before sending a close event.
        // This prevents quick app swaps, navigation pulls, etc.
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: NotificareDefinitions.Tasks.applicationClose) { [weak self] in
            Notificare.shared.logger.debug("Background task expiration handler triggered.")
            guard let self = self else {
                return
            }

            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
            self.workItem = nil
        }

        let workItem = createWorkItem()
        self.workItem = workItem
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: workItem)
    }

    private func createWorkItem() -> DispatchWorkItem {
        DispatchWorkItem {
            guard let sessionId = self.sessionId,
                let sessionStart = self.sessionStart,
                let sessionEnd = self.sessionEnd
            else {
                // Skip when no session has started. Should never happen.
                return
            }

            let length = sessionEnd.timeIntervalSince(sessionStart)
            Notificare.shared.logger.info("Application closed event registered for session '\(sessionId)' with a length of \(length) seconds.")
            Notificare.shared.eventsManager.logApplicationClose(length: length)

            // Reset the session.
            self.sessionId = nil
            self.sessionStart = nil
            self.sessionEnd = nil

            // Clear the background task.
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.workItem = nil
        }
    }
}
