//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificarePushApi {
    typealias Completion<T> = (Result<T, NotificareError>) -> Void

    private let baseUrl: URL
    private let applicationKey: String
    private let applicationSecret: String
    private let session: URLSession
    private let decoder = NotificareUtils.createJsonDecoder()
    private let encoder = NotificareUtils.createJsonEncoder()

    init(applicationKey: String, applicationSecret: String, session: URLSession = URLSession.shared, environment: NotificareEnvironment = .production) {
        baseUrl = environment.getConfiguration().pushHost
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

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(ApplicationInfoResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.application))
            }
        }
    }

    func createDevice(with deviceRegistration: NotificareDeviceRegistration, _ completion: @escaping Completion<Void>) {
        let url = baseUrl.appendingPathComponent("device")

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let encoded = try? encoder.encode(deviceRegistration) else {
            completion(.failure(.parsingFailure))
            return
        }

        request.httpMethod = "POST"
        request.httpBody = encoded

        session.perform(request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            }
        }
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateBackgroundAppRefresh, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateBluetoothState, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateLanguage, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateLocation, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateNotificationSettings, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    func updateDevice(_ id: String, with payload: NotificareDeviceUpdateTimezone, _ completion: @escaping Completion<Void>) {
        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        updateDevice(id, with: encoded, completion)
    }

    private func updateDevice(_ id: String, with payload: Data, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)

        request.httpMethod = "PUT"
        request.httpBody = payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func deleteDevice(_ id: String, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)

        request.httpMethod = "DELETE"

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func getDeviceTags(with id: String, _ completion: @escaping Completion<[String]>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("tags")

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(DeviceTagsResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.tags))
            }
        }
    }

    func logEvent(_ event: NotificareEvent, _ completion: @escaping Completion<Void>) {
        let url = baseUrl.appendingPathComponent("event")

        var request = URLRequest(url: url)
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)

        guard let encoded = try? encoder.encode(event) else {
            completion(.failure(.parsingFailure))
            return
        }

        request.httpMethod = "POST"
        request.httpBody = encoded
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }
}
