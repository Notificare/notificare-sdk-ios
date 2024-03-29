//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

private let MAX_RETRIES = 5
private let UPLOAD_TASK_NAME = "re.notifica.tasks.events.Upload"

internal class NotificareEventsModuleImpl: NSObject, NotificareModule, NotificareEventsModule, NotificareInternalEventsModule {
    private let discardableEvents = [String]()
    private var processEventsTaskIdentifier: UIBackgroundTaskIdentifier?

    // MARK: - Notificare Module

    static let instance = NotificareEventsModuleImpl()

    func configure() {
        // Listen to application did become active events.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        // Listen to reachability changed events.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReachabilityChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: nil)
    }

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        processStoredEvents()
        completion(.success(()))
    }

    // MARK: - Notificare Events

    func logNotificationOpen(_ id: String, _ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.notification.Open", data: nil, notificationId: id, completion)
    }

    @available(iOS 13.0, *)
    func logNotificationOpen(_ id: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            logNotificationOpen(id) { result in
                continuation.resume(with: result)
            }
        }
    }

    func logCustom(_ event: String, data: NotificareEventData?, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isReady else {
            completion(.failure(NotificareError.notReady))
            return
        }

        log("re.notifica.event.custom.\(event)", data: data, completion)
    }

    @available(iOS 13.0, *)
    func logCustom(_ event: String, data: NotificareEventData?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            logCustom(event, data: data) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Notificare Internal Events

    func log(_ event: String, data: NotificareEventData?, sessionId: String?, notificationId: String?, _ completion: @escaping NotificareCallback<Void>) {
        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        let event = NotificareEvent(
            type: event,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            deviceId: device.id,
            sessionId: sessionId ?? Notificare.shared.session().sessionId,
            notificationId: notificationId,
            userId: device.userId,
            data: data
        )

        log(event, completion)
    }

    // MARK: - Internal API

    internal func logApplicationInstall(_ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.application.Install", completion)
    }

    internal func logApplicationRegistration(_ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.application.Registration", completion)
    }

    internal func logApplicationUpgrade(_ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.application.Upgrade", completion)
    }

    internal func logApplicationOpen(sessionId: String, _ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.application.Open", sessionId: sessionId, completion)
    }

    internal func logApplicationClose(sessionId: String, sessionLength: Double, _ completion: @escaping NotificareCallback<Void>) {
        log("re.notifica.event.application.Close", data: ["length": String(sessionLength)], sessionId: sessionId, completion)
    }

    private func log(_ event: NotificareEvent, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isConfigured else {
            NotificareLogger.debug("Notificare is not configured. Cannot log the event.")
            completion(.failure(NotificareError.notConfigured))
            return
        }

        NotificareRequest.Builder()
            .post("/event", body: event)
            .response { result in
                switch result {
                case .success:
                    NotificareLogger.info("Event '\(event.type)' sent successfully.")
                    completion(.success(()))
                case let .failure(error):
                    NotificareLogger.warning("Failed to send the event '\(event.type)'.", error: error)

                    if !self.discardableEvents.contains(event.type), let error = error as? NotificareNetworkError, error.recoverable {
                        NotificareLogger.info("Queuing event to be sent whenever possible.")

                        Notificare.shared.database.add(event)
                        self.processStoredEvents()

                        completion(.success(()))
                        return
                    }

                    completion(.failure(error))
                }
            }
    }

    private func processStoredEvents() {
        // Check that Notificare is ready to process the events.
        guard Notificare.shared.state >= .configured else {
            NotificareLogger.debug("Notificare is not ready yet. Skipping...")
            return
        }

        // Ensure there is no running task.
        guard processEventsTaskIdentifier == nil else {
            NotificareLogger.debug("There's an upload task running. Skipping...")
            return
        }

        // Run the task on a background queue.
        DispatchQueue.global(qos: .background).async {
            // Notify the system about a long running task.
            self.processEventsTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: UPLOAD_TASK_NAME) {
                // Check the task is still running.
                guard let taskId = self.processEventsTaskIdentifier else {
                    return
                }

                // Stop the task if the given time expires.
                NotificareLogger.debug("Completing background task after its expiration.")
                UIApplication.shared.endBackgroundTask(taskId)
                self.processEventsTaskIdentifier = nil
            }

            // Load and process the stored events.
            if let events = try? Notificare.shared.database.fetchEvents() {
                self.process(events)
            }

            // Check the task is still running.
            guard let taskId = self.processEventsTaskIdentifier else {
                return
            }

            // Stop the task if the given time expires.
            NotificareLogger.debug("Completing background task after processing all the events.")
            UIApplication.shared.endBackgroundTask(taskId)
            self.processEventsTaskIdentifier = nil
        }
    }

    private func process(_ managedEvents: [NotificareCoreDataEvent]) {
        guard processEventsTaskIdentifier != nil else {
            NotificareLogger.debug("The background task was terminated before all the events could be processed.")
            return
        }

        var events = managedEvents
        guard !events.isEmpty else {
            NotificareLogger.debug("Nothing to process.")
            return
        }

        let event = events.removeFirst()
        process(event)

        if events.isEmpty {
            NotificareLogger.debug("Finished processing all the events.")
            return
        }

        NotificareLogger.debug("\(events.count) events remaining. Processing next...")
        process(events)
    }

    private func process(_ managedEvent: NotificareCoreDataEvent) {
        let createdAt = Date(timeIntervalSince1970: Double(managedEvent.timestamp / 1000))
        let expiresAt = createdAt.addingTimeInterval(Double(managedEvent.ttl))
        let now = Date()

        if now > expiresAt {
            NotificareLogger.debug("Event expired. Removing...")
            Notificare.shared.database.remove(managedEvent)
            return
        }

        let event: NotificareEvent

        do {
            event = try NotificareEvent(from: managedEvent)
        } catch {
            NotificareLogger.debug("Cleaning up a corrupted event in the database.")
            Notificare.shared.database.remove(managedEvent)
            return
        }

        // Leverage a DispatchGroup to wait for the request.
        let group = DispatchGroup()
        group.enter()

        // Perform the network request, which can retry internally.
        NotificareRequest.Builder()
            .post("/event", body: event)
            .response { result in
                switch result {
                case .success:
                    NotificareLogger.debug("Event processed. Removing from storage...")
                    Notificare.shared.database.remove(managedEvent)
                case let .failure(error):
                    if let error = error as? NotificareNetworkError, error.recoverable {
                        NotificareLogger.debug("Failed to process event.")

                        // Increase the attempts counter.
                        managedEvent.retries += 1

                        if managedEvent.retries < MAX_RETRIES {
                            // Persist the attempts counter.
                            Notificare.shared.database.saveChanges()
                        } else {
                            NotificareLogger.debug("Event was retried too many times. Removing...")
                            Notificare.shared.database.remove(managedEvent)
                        }
                    } else {
                        NotificareLogger.debug("Failed to process event due to an unrecoverable error. Discarding it...")
                        Notificare.shared.database.remove(managedEvent)
                    }
                }

                group.leave()
            }

        // Wait until the request finishes.
        group.wait()
    }

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        guard Notificare.shared.isReady else { return }

        processStoredEvents()
    }

    @objc private func onReachabilityChanged(_: Notification) {
        guard let reachability = Notificare.shared.reachability else {
            NotificareLogger.debug("Reachbility module not configure.")
            return
        }

        guard Notificare.shared.isReady else { return }

        switch reachability.connection {
        case .unavailable:
            guard let taskId = processEventsTaskIdentifier else {
                return
            }

            // Stop the task if there is no connectivity.
            NotificareLogger.debug("Stopping background task due to lack of connectivity.")
            UIApplication.shared.endBackgroundTask(taskId)
            processEventsTaskIdentifier = nil
        case .cellular, .wifi:
            NotificareLogger.debug("Starting background task to upload stored events.")
            processStoredEvents()
        }
    }
}

// MARK: - Recoverable NotificareError

private extension NotificareNetworkError {
    var recoverable: Bool {
        switch self {
        case .genericError,
             .inaccessible,
             .urlError:
            return true
        default:
            return false
        }
    }
}
