//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareCore

public struct NotificarePushApi {
    public typealias Completion<T> = (Result<T, NotificareError>) -> Void

    public let baseUrl: URL
    public let applicationKey: String
    public let applicationSecret: String
    public let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil

        return URLSession(configuration: configuration)
    }()

    public let decoder = NotificareUtils.jsonDecoder
    public let encoder = NotificareUtils.jsonEncoder

    init(applicationKey: String, applicationSecret: String, services: NotificareServices = .production) {
        baseUrl = services.pushHost
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
    }

    func getApplicationInfo(_ completion: @escaping Completion<NotificareApplication>) {
        let url = baseUrl
            .appendingPathComponent("application")
            .appendingPathComponent("info")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareApplicationInfoResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.application))
            }
        }
    }

    func createDevice(with deviceRegistration: NotificareDeviceRegistration, _ completion: @escaping Completion<Void>) {
        let url = baseUrl.appendingPathComponent("device")

        guard let encoded = try? encoder.encode(deviceRegistration) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("POST", payload: encoded)

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
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT", payload: payload)

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
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("DELETE")

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
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareDeviceTagsResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.tags))
            }
        }
    }

    func addDeviceTags(with id: String, payload: NotificareTagsPayload, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("addtags")

        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT", payload: encoded)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func removeDeviceTags(with id: String, payload: NotificareTagsPayload, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("removetags")

        guard let encoded = try? encoder.encode(payload) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT", payload: encoded)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func clearDeviceTags(with id: String, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("cleartags")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func fetchDeviceDoNotDisturb(_ id: String, _ completion: @escaping Completion<NotificareDoNotDisturb?>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("dnd")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareDoNotDisturbResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.dnd))
            }
        }
    }

    func updateDeviceDoNotDisturb(_ id: String, dnd: NotificareDoNotDisturb, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("dnd")

        guard let encoded = try? encoder.encode(dnd) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT", payload: encoded)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func clearDeviceDoNotDisturb(_ id: String, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("cleardnd")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func fetchDeviceUserData(_ id: String, _ completion: @escaping Completion<NotificareUserData?>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("userdata")

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareUserDataResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.userData))
            }
        }
    }

    func updateDeviceUserData(_ id: String, userData: NotificareUserData, _ completion: @escaping Completion<Void>) {
        let url = baseUrl
            .appendingPathComponent("device")
            .appendingPathComponent(id)
            .appendingPathComponent("userdata")

        guard let encoded = try? encoder.encode(userData) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("PUT", payload: encoded)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func logEvent(_ event: NotificareEvent, _ completion: @escaping Completion<Void>) {
        let url = baseUrl.appendingPathComponent("event")

        guard let encoded = try? encoder.encode(event) else {
            completion(.failure(.parsingFailure))
            return
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("POST", payload: encoded)

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case .success:
                completion(.success(()))
            }
        }
    }

    func getDynamicLink(_ link: String, _ completion: @escaping Completion<NotificareDynamicLink>) {
        var url = baseUrl
            .appendingPathComponent("link")
            .appendingPathComponent("dynamic")
            .appendingPathComponent(link.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            .appendingQueryComponent(name: "platform", value: "iOS")

        if let device = Notificare.shared.deviceManager.currentDevice {
            url.appendQueryComponent(name: "deviceID", value: device.id)
        }

        if let userId = Notificare.shared.deviceManager.currentDevice?.userId {
            url.appendQueryComponent(name: "userID", value: userId)
        }

        var request = URLRequest(url: url)
        request.setNotificareHeaders()
        request.setBasicAuthentication(username: applicationKey, password: applicationSecret)
        request.setMethod("GET")

        session.perform(request) { result in
            switch result {
            case let .failure(error):
                completion(.failure(.networkFailure(cause: error)))
            case let .success(data):
                guard let decoded = try? self.decoder.decode(NotificareDynamicLinkResponse.self, from: data) else {
                    completion(.failure(NotificareError.parsingFailure))
                    return
                }

                completion(.success(decoded.link))
            }
        }
    }

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

    func createNotificationReply(_ payload: NotificareCreateReplyPayload, _ completion: @escaping Completion<Void>) {
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

    func uploadNotificationReplyAsset(_ data: Data, contentType: String, _ completion: @escaping Completion<String>) {
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
