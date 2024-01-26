//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

private let SESSION_CLOSE_TASK_NAME = "re.notifica.tasks.session.Close"

internal class NotificareSessionModuleImpl: NSObject, NotificareModule {
    internal private(set) var sessionId: String?
    private var sessionStart: Date?
    private var sessionEnd: Date?

    private var backgroundTask: DispatchWorkItem?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        return formatter
    }()

    // MARK: - Notificare Module

    static let instance = NotificareSessionModuleImpl()

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

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        if sessionId == nil, Notificare.shared.device().currentDevice != nil, UIApplication.shared.applicationState == .active {
            // Launch is taking place after the application came to the foreground.
            // Start the application session.
            startSession { _ in
                completion(.success(()))
            }

            return
        }

        completion(.success(()))
    }

    func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
        sessionEnd = Date()
        stopSession { _ in
            completion(.success(()))
        }
    }

    // MARK: - Internal API

    @objc private func applicationDidBecomeActive() {
        guard UIApplication.shared.applicationState == .active else {
            NotificareLogger.debug("The application is not active. Skipping...")
            return
        }

        if sessionId != nil {
            NotificareLogger.debug("Resuming previous session.")
        }

        // Cancel any session timeout.
        cancelBackgroundTask()

        // Prevent multiple session starts.
        guard sessionId == nil else { return }

        guard Notificare.shared.isReady else {
            NotificareLogger.debug("Postponing session start until Notificare is launched.")
            return
        }

        Task {
            try await startSession()
        }
    }

    @objc private func applicationWillResignActive() {
        guard UIApplication.shared.applicationState == .active else {
            NotificareLogger.debug("The application is not active. Skipping...")
            return
        }

        sessionEnd = Date()

        // Wait a few seconds before sending a close event.
        // This prevents quick app swaps, navigation pulls, etc.
        let backgroundTask = createBackgroundTask()
        self.backgroundTask = backgroundTask
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10, execute: backgroundTask)

        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: SESSION_CLOSE_TASK_NAME) { [weak self] in
            NotificareLogger.debug("Background task expiration handler triggered.")
            self?.cancelBackgroundTask()
        }
    }

    private func startSession(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await startSession()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func startSession() async throws {
        let sessionId = UUID().uuidString.lowercased()
        let sessionStart = Date()

        self.sessionId = sessionId
        self.sessionStart = sessionStart
        sessionEnd = nil

        NotificareLogger.debug("Session '\(sessionId)' started at \(dateFormatter.string(from: sessionStart)).")

        do {
            try await Notificare.shared.eventsImplementation().logApplicationOpen(sessionId: sessionId)
            return
        } catch {
            NotificareLogger.warning("Failed to process an application session start.", error: error)
        }
    }

    private func stopSession(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await stopSession()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func stopSession() async throws {
        guard let sessionId = sessionId,
              let sessionStart = sessionStart,
              let sessionEnd = sessionEnd
        else {
            // Skip when no session has started. Should never happen.
            return
        }

        // Reset the session.
        self.sessionId = nil
        self.sessionStart = nil
        self.sessionEnd = nil

        NotificareLogger.debug("Session '\(sessionId)' stopped at \(dateFormatter.string(from: sessionEnd)).")

        let length = sessionEnd.timeIntervalSince(sessionStart)
        do {
            try await Notificare.shared.eventsImplementation().logApplicationClose(sessionId: sessionId, sessionLength: length)
        } catch {
            NotificareLogger.warning("Failed to process an application session stop.", error: error)
        }
    }

    private func createBackgroundTask() -> DispatchWorkItem {
        DispatchWorkItem {
            self.stopSession { _ in
                self.cancelBackgroundTask()
            }
        }
    }

    private func cancelBackgroundTask() {
        backgroundTask?.cancel()
        backgroundTask = nil

        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }
    }
}
