//
// Created by Helder Pinhal on 04/08/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

fileprivate let MAX_RETRIES = 5

public class NotificareEventLogger {

    private let discardableEvents = [String]()
    private var uploadTaskId: UIBackgroundTaskIdentifier?


    func configure() {
        _ = NotificareSwizzler.addInterceptor(self)
    }

    public func logCustom(_ event: String, data: NotificareEventData? = nil) {
        self.log("re.notifica.event.custom.\(event)", data: data)
    }


    private func log(_ event: String, data: NotificareEventData? = nil) {
        guard let device = NotificareDeviceManager.shared.device else {
            Notificare.shared.logger.warning("Cannot send an event before a device is registered.")
            return
        }

        let event = NotificareEvent(
            type: event,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            deviceId: device.deviceID,
            sessionId: NotificareDeviceManager.shared.sessionId,
            notificationId: nil,
            userId: device.userID,
            data: data
        )

        self.log(event)
    }

    private func log(_ event: NotificareEvent) {
//        Notificare.shared.pushApi?.logEvent(event) { result in
//            switch result {
//            case .success:
//                Notificare.shared.logger.info("Event sent successfully.")
//            case .failure(let error):
//                Notificare.shared.logger.warning("Failed to send the event: \(event.type).")
//                Notificare.shared.logger.debug("\(error)")
//
//                if !self.discardableEvents.contains(event.type) {
//                    Notificare.shared.logger.info("Queuing to be sent whenever possible.")

        Notificare.shared.coreDataManager.add(event)
//                }
//            }
//        }
    }
}

// MARK: - NotificareAppDelegateInterceptor

extension NotificareEventLogger: NotificareAppDelegateInterceptor {

    public func applicationDidBecomeActive(_ application: UIApplication) {
        guard Notificare.shared.state == .ready else {
            Notificare.shared.logger.verbose("Notificare is not ready yet. Skipping...")
            return
        }

        guard self.uploadTaskId == nil else {
            Notificare.shared.logger.verbose("There's an upload task running. Skipping...")
            return
        }

        do {
            Notificare.shared.logger.debug("Uploading cached events.")
            let dbEvents = try Notificare.shared.coreDataManager.fetchEvents()

            dbEvents.forEach { managedEvent in
                let createdAt = Date(timeIntervalSince1970: Double(managedEvent.timestamp / 1000))
                let expiresAt = createdAt.addingTimeInterval(Double(managedEvent.ttl))
                let now = Date()

                if now > expiresAt {
                    Notificare.shared.logger.verbose("Event expired. Removing...")
                    Notificare.shared.coreDataManager.remove(managedEvent)
                    return
                }

                if managedEvent.retries > MAX_RETRIES {
                    Notificare.shared.logger.verbose("Event was retried too many times. Removing...")
                    Notificare.shared.coreDataManager.remove(managedEvent)
                    return
                }

                let event = NotificareEvent(from: managedEvent)
                Notificare.shared.pushApi?.logEvent(event, { result in
                    switch result {
                    case .success:
                        Notificare.shared.logger.debug("Event upload processed. Removing from cache...")
                        Notificare.shared.coreDataManager.remove(managedEvent)
                    case .failure(let error):
                        if error.recoverable {
                            // TODO increment retries variable
                        } else {
                            Notificare.shared.coreDataManager.remove(managedEvent)
                        }
                    }
                })
            }
        } catch {
            Notificare.shared.logger.error("Failed to upload cached events: \(error)")
        }
    }
}

fileprivate extension NotificareError {
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
