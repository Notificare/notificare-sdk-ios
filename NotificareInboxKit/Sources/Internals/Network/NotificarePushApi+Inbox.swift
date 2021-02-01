//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit

extension NotificarePushApi {
    func getInbox(for deviceId: String, since: Int64? = nil, skip: Int = 0, limit: Int = 100, _ completion: @escaping Completion<NotificareInboxResponse>) {
        var url = baseUrl
            .appendingPathComponent("notification")
            .appendingPathComponent("inbox")
            .appendingPathComponent("fordevice")
            .appendingPathComponent(deviceId)
            .appendingQueryComponent(name: "skip", value: String(format: "%d", skip))
            .appendingQueryComponent(name: "limit", value: String(format: "%d", limit))

        if let since = since {
            url.appendQueryComponent(name: "ifModifiedSince", value: "\(since)")
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .success(data):
                do {
                    let decoded = try self.decoder.decode(NotificareInboxResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(NotificareError.parsingFailure))
                }
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            }
        }
    }

    func markAllAsRead(for deviceId: String, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("notification")
            .appendingPathComponent("inbox")
            .appendingPathComponent("fordevice")
            .appendingPathComponent(deviceId)

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT")

        session.perform(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            }
        }
    }

    func removeItem(_ item: NotificareInboxItem, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("notification")
            .appendingPathComponent("inbox")
            .appendingPathComponent(item.id)

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("DELETE")

        session.perform(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            }
        }
    }

    func clearInbox(for deviceId: String, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("notification")
            .appendingPathComponent("inbox")
            .appendingPathComponent("fordevice")
            .appendingPathComponent(deviceId)

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("DELETE")

        session.perform(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            }
        }
    }
}
