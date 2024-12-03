//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import NotificareUtilitiesKit

internal class NotificareUserInboxImpl: NotificareModule, NotificareUserInbox {
    // MARK: - Notificare module

    internal static let instance = NotificareUserInboxImpl()

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false
    }

    // MARK: - Notificare user inbox

    public func parseResponse(string: String) throws -> NotificareUserInboxResponse {
        guard let data = string.data(using: .utf8) else {
            throw NotificareUserInboxError.dataCorrupted
        }

        return try parseResponse(data: data)
    }

    public func parseResponse(json: [String: Any]) throws -> NotificareUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try parseResponse(data: data)
    }

    public func parseResponse(data: Data) throws -> NotificareUserInboxResponse {
        try JSONDecoder.notificare.decode(NotificareUserInboxResponse.self, from: data)
    }

    public func open(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        Task {
            do {
                let result = try await open(item)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func open(_ item: NotificareUserInboxItem) async throws -> NotificareNotification {
        try checkPrerequisites()

        let notification = try await fetchUserInboxNotification(item)

        // Mark the item as read & send a notification open event.
        try await markAsRead(item)
        return notification
    }

    public func markAsRead(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await markAsRead(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func markAsRead(_ item: NotificareUserInboxItem) async throws {
        try checkPrerequisites()

        try await Notificare.shared.events().logNotificationOpen(item.notification.id)

        Notificare.shared.removeNotificationFromNotificationCenter(item.notification)
    }

    public func remove(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await remove(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func remove(_ item: NotificareUserInboxItem) async throws {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        try await NotificareRequest.Builder()
            .delete("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .response()

        Notificare.shared.removeNotificationFromNotificationCenter(item.notification)
    }

    // MARK: - Private API

    private func checkPrerequisites() throws {
        guard Notificare.shared.isReady else {
            logger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.inbox.rawValue] == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useUserInbox == true else {
            logger.warning("Notificare user inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }
    }

    private func fetchUserInboxNotification(_ item: NotificareUserInboxItem) async throws -> NotificareNotification {
        guard Notificare.shared.isConfigured else {
            throw NotificareError.notConfigured
        }

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.notConfigured
        }

        let response = try await NotificareRequest.Builder()
            .get("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserInboxNotification.self)

        return response.notification.toModel()
    }
}
