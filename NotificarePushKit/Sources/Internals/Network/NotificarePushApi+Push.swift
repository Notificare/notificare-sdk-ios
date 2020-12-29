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
}
