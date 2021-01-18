//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension NotificarePushApi {
    func getNotification(_ id: String, _ completion: @escaping Completion<NotificareNotification>) {
        let url = baseUrl
            .appendingPathComponent("notification")
            .appendingPathComponent(id)

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareNotificationResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.notification))
            }
        }
    }

    func createNotificationActionReply(_ payload: NotificareCreateReplyPayload, _ completion: @escaping Completion<Void>) {
        let url = baseUrl.appendingPathComponent("reply")

        guard let data = try? encoder.encode(payload) else {
            completion(.failure(.encodingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("POST", payload: data)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func uploadNotificationActionReplyAsset(_ data: Data, contentType: String, _ completion: @escaping Completion<String>) {
        let url = baseUrl
            .appendingPathComponent("upload")
            .appendingPathComponent("reply")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareUploadResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.filename))
            }
        }
    }
}
