//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificarePushApi {

    typealias Completion<T> = (Result<T, NotificareError>) -> Void

    private let baseUrl: URL
    private let applicationKey: String
    private let applicationSecret: String
    private let session: URLSession
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }()

    init(applicationKey: String, applicationSecret: String, session: URLSession = URLSession.shared, environment: NotificareEnvironment = .production) {
        self.baseUrl = environment.getConfiguration().pushHost
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.session = session
    }


    func getApplicationInfo(_ completion: @escaping Completion<NotificareApplicationInfo>) {
        let url = baseUrl
                .appendingPathComponent("application")
                .appendingPathComponent("info")

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)

        self.session.perform(request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.networkFailure(cause: error)))
            case .success(let data):
                guard let decoded = try? self.decoder.decode(ApplicationInfoResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.application))
            }
        }
    }
}
