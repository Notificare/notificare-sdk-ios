//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal class NotificareUserInboxImpl: NotificareModule, NotificareUserInbox {
    // MARK: - Notificare module

    static let instance = NotificareUserInboxImpl()

    // MARK: - Notificare user inbox

    func parseResponse(string: String) throws -> NotificareUserInboxResponse {
        guard let data = string.data(using: .utf8) else {
            throw NotificareUserInboxError.dataCorrupted
        }

        return try parseResponse(data: data)
    }

    func parseResponse(json: [String: Any]) throws -> NotificareUserInboxResponse {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try parseResponse(data: data)
    }

    func parseResponse(data: Data) throws -> NotificareUserInboxResponse {
        try NotificareUtils.jsonDecoder.decode(NotificareUserInboxResponse.self, from: data)
    }

    func open(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        // User inbox items are always partial.
        fetchUserInboxNotification(item) { result in
            switch result {
            case let .success(notification):
                // Mark the item as read & send a notification open event.
                self.markAsRead(item) { result in
                    switch result {
                    case .success:
                        completion(.success(notification))

                    case let .failure(error):
                        completion(.failure(error))
                    }
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    @available(iOS 13.0, *)
    func open(_ item: NotificareUserInboxItem) async throws -> NotificareNotification {
        try await withCheckedThrowingContinuation { continuation in
            open(item) { result in
                continuation.resume(with: result)
            }
        }
    }

    func markAsRead(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        Notificare.shared.events().logNotificationOpen(item.notification.id) { result in
            completion(result)
        }
    }

    @available(iOS 13.0, *)
    func markAsRead(_ item: NotificareUserInboxItem) async throws {
        try await withCheckedThrowingContinuation { continuation in
            markAsRead(item) { result in
                continuation.resume(with: result)
            }
        }
    }

    func remove(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .delete("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func remove(_ item: NotificareUserInboxItem) async throws {
        try await withCheckedThrowingContinuation { continuation in
            remove(item) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Private API

    private func checkPrerequisites() throws {
        guard Notificare.shared.isReady else {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.inbox.rawValue] == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useUserInbox == true else {
            NotificareLogger.warning("Notificare user inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }
    }

    private func fetchUserInboxNotification(_ item: NotificareUserInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        guard Notificare.shared.isConfigured else {
            completion(.failure(NotificareError.notConfigured))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.notConfigured))
            return
        }

        NotificareRequest.Builder()
            .get("/notification/userinbox/\(item.id)/fordevice/\(device.id)")
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserInboxNotification.self) { result in
                switch result {
                case let .success(response):
                    completion(.success(response.notification.toModel()))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}
