//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

private let maxRetries = 5

public class NotificareEventsModule {
    private let discardableEvents = [String]()
    private var processEventsTaskIdentifier: UIBackgroundTaskIdentifier?

    func configure() {
        _ = NotificareSwizzler.addInterceptor(self)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(notification:)),
                                               name: .reachabilityChanged,
                                               object: nil)
    }

    func launch() {
        processStoredEvents()
    }

    public func logApplicationInstall() {
        log(NotificareDefinitions.Events.applicationInstall)
    }

    public func logApplicationRegistration() {
        log(NotificareDefinitions.Events.applicationRegistration)
    }

    public func logApplicationUpgrade() {
        log(NotificareDefinitions.Events.applicationUpgrade)
    }

    public func logApplicationOpen() {
        log(NotificareDefinitions.Events.applicationOpen)
    }

    public func logApplicationClose(length _: TimeInterval) {
        log(NotificareDefinitions.Events.applicationClose)
    }

    public func logCustom(_ event: String, data: NotificareEventData? = nil) {
        log("re.notifica.event.custom.\(event)", data: data)
    }

    private func log(_ event: String, data: NotificareEventData? = nil) {
        guard let device = Notificare.shared.device.device else {
            Notificare.shared.logger.warning("Cannot send an event before a device is registered.")
            return
        }

        let event = NotificareEvent(
            type: event,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            deviceId: device.deviceID,
            sessionId: Notificare.shared.session.currentSession,
            notificationId: nil,
            userId: device.userID,
            data: data
        )

        log(event)
    }

    private func log(_ event: NotificareEvent) {
        Notificare.shared.pushApi?.logEvent(event) { result in
            switch result {
            case .success:
                Notificare.shared.logger.info("Event sent successfully.")
            case let .failure(error):
                Notificare.shared.logger.warning("Failed to send the event: \(event.type).")
                Notificare.shared.logger.debug("\(error)")

                if !self.discardableEvents.contains(event.type) && error.recoverable {
                    Notificare.shared.logger.info("Queuing to be sent whenever possible.")

                    Notificare.shared.database.add(event)
                }
            }
        }
    }
}

// MARK: - NotificareAppDelegateInterceptor

extension NotificareEventsModule: NotificareAppDelegateInterceptor {
    public func applicationDidBecomeActive(_: UIApplication) {
        processStoredEvents()
    }

    private func processStoredEvents() {
        // Check that Notificare is ready to process the events.
        guard Notificare.shared.state >= .ready else {
            Notificare.shared.logger.verbose("Notificare is not ready yet. Skipping...")
            return
        }

        // Ensure there is no running task.
        guard processEventsTaskIdentifier == nil else {
            Notificare.shared.logger.verbose("There's an upload task running. Skipping...")
            return
        }

        // Run the task on a background queue.
        DispatchQueue.global(qos: .background).async {
            // Notify the system about a long running task.
            self.processEventsTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: NotificareDefinitions.Tasks.processEvents) {
                // Check the task is still running.
                guard let taskId = self.processEventsTaskIdentifier else {
                    return
                }

                // Stop the task if the given time expires.
                Notificare.shared.logger.debug("Completing background task after its expiration.")
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
            Notificare.shared.logger.debug("Completing background task after processing all the events.")
            UIApplication.shared.endBackgroundTask(taskId)
            self.processEventsTaskIdentifier = nil
        }
    }

    private func process(_ managedEvents: [NotificareCoreDataEvent]) {
        guard processEventsTaskIdentifier != nil else {
            Notificare.shared.logger.debug("The background task was terminated before all the events could be processed.")
            return
        }

        var events = managedEvents
        guard !events.isEmpty else {
            Notificare.shared.logger.debug("Nothing to process.")
            return
        }

        let event = events.removeFirst()
        process(event)

        if events.isEmpty {
            Notificare.shared.logger.debug("Finished processing all the events.")
            return
        }

        Notificare.shared.logger.verbose("\(events.count) events remaining. Processing next...")
        process(events)
    }

    private func process(_ managedEvent: NotificareCoreDataEvent) {
        let createdAt = Date(timeIntervalSince1970: Double(managedEvent.timestamp / 1000))
        let expiresAt = createdAt.addingTimeInterval(Double(managedEvent.ttl))
        let now = Date()

        if now > expiresAt {
            Notificare.shared.logger.verbose("Event expired. Removing...")
            Notificare.shared.database.remove(managedEvent)
            return
        }

        let event = NotificareEvent(from: managedEvent)

        // Leverage a DispatchGroup to wait for the request.
        let group = DispatchGroup()
        group.enter()

        // Perform the network request, which can retry internally.
        Notificare.shared.pushApi!.logEvent(event) { result in
            switch result {
            case .success:
                Notificare.shared.logger.verbose("Event processed. Removing from storage...")
                Notificare.shared.database.remove(managedEvent)
            case let .failure(error):
                if error.recoverable {
                    Notificare.shared.logger.verbose("Failed to process event.")

                    // Increase the attempts counter.
                    managedEvent.retries += 1

                    if managedEvent.retries < maxRetries {
                        // Persist the attempts counter.
                        Notificare.shared.database.save()
                    } else {
                        Notificare.shared.logger.verbose("Event was retried too many times. Removing...")
                        Notificare.shared.database.remove(managedEvent)
                    }
                } else {
                    Notificare.shared.logger.verbose("Failed to process event due to an unrecoverable error. Discarding it...")
                    Notificare.shared.database.remove(managedEvent)
                }
            }

            group.leave()
        }

        // Wait until the request finishes.
        group.wait()
    }
}

// MARK: - Reachability

extension NotificareEventsModule {
    @objc private func reachabilityChanged(notification _: Notification) {
        guard let reachability = Notificare.shared.reachability else {
            Notificare.shared.logger.debug("Reachbility module not configure.")
            return
        }

        switch reachability.connection {
        case .unavailable:
            guard let taskId = processEventsTaskIdentifier else {
                return
            }

            // Stop the task if there is no connectivity.
            Notificare.shared.logger.debug("Stopping background task due to lack of connectivity.")
            UIApplication.shared.endBackgroundTask(taskId)
            processEventsTaskIdentifier = nil
        case .cellular, .wifi:
            Notificare.shared.logger.debug("Starting background task to upload stored events.")
            processStoredEvents()
        }
    }
}

// MARK: - Recoverable NotificareError

private extension NotificareError {
    var recoverable: Bool {
        if case let .networkFailure(cause) = self {
            switch cause {
            case .genericError,
                 .inaccessible,
                 .urlError:
                return true
            default:
                return false
            }
        }

        return false
    }
}