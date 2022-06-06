//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

private let SESSION_CLOSE_TASK_NAME = "re.notifica.tasks.session.Close"

internal class NotificareSessionModuleImpl: NSObject, NotificareModule {
    internal static let instance = NotificareSessionModuleImpl()

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

    // MARK: - Notificare Module

    static func configure() {
        // Listen to 'application did become active'
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to 'application will resign active'
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    // MARK: - Internal API

    @objc private func applicationDidBecomeActive() {
        guard UIApplication.shared.applicationState == .active else {
            return
        }

        // Cancel any session timeout.
        workItem?.cancel()
        UIApplication.shared.endBackgroundTask(backgroundTask)

        guard sessionStart == nil else {
            NotificareLogger.debug("Resuming previous session.")
            return
        }

        let sessionId = UUID().uuidString.lowercased()
        let sessionStart = Date()

        self.sessionId = sessionId
        self.sessionStart = sessionStart
        sessionEnd = nil

        NotificareLogger.debug("Session '\(sessionId)' started at \(dateFormatter.string(from: sessionStart)).")
        Notificare.shared.eventsImplementation().logApplicationOpen(sessionId: sessionId) { _ in }
    }

    @objc private func applicationWillResignActive() {
        guard UIApplication.shared.applicationState == .active else {
            NotificareLogger.debug("Application is not active. Skipping...")
            return
        }

        guard let sessionId = sessionId else {
            NotificareLogger.debug("No session found. Skipping...")
            return
        }

        let sessionEnd = Date()
        self.sessionEnd = sessionEnd

        NotificareLogger.debug("Session '\(sessionId)' stopped at \(dateFormatter.string(from: sessionEnd)).")

        // Wait a few seconds before sending a close event.
        // This prevents quick app swaps, navigation pulls, etc.
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: SESSION_CLOSE_TASK_NAME) { [weak self] in
            NotificareLogger.debug("Background task expiration handler triggered.")
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
            NotificareLogger.info("Application closed event registered for session '\(sessionId)' with a length of \(length) seconds.")
            Notificare.shared.eventsImplementation().logApplicationClose(sessionId: sessionId, sessionLength: length) { _ in }

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
