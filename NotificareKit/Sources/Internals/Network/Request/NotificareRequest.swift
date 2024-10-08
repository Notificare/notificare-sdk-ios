//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit
import NotificareUtilitiesKit

public struct NotificareRequest {
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil

        return URLSession(configuration: configuration)
    }()

    private let request: URLRequest
    private let validStatusCodes: ClosedRange<Int>

    public func response(_ completion: @escaping NotificareCallback<(response: HTTPURLResponse, data: Data?)>) {
        NotificareRequest.session.perform(request) { result in
            switch result {
            case .success(let (response, data)):
                handleResponse(response, data: data, completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func responseDecodable<T: Decodable>(_ type: T.Type, _ completion: @escaping (Result<T, Error>) -> Void) {
        response { result in
            switch result {
            case let .success((response, data)):
                guard let data = data else {
                    completion(.failure(NotificareNetworkError.noResponseData(response)))
                    return
                }

                do {
                    let model = try JSONDecoder.notificare.decode(type, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func handleResponse(_ response: HTTPURLResponse, data: Data?, _ completion: @escaping NotificareCallback<(response: HTTPURLResponse, data: Data?)>) {
        guard validStatusCodes.contains(response.statusCode) else {
            completion(.failure(NotificareNetworkError.validationError(response: response, data: data, validStatusCodes: validStatusCodes)))
            return
        }

        completion(.success((response, data)))
    }

    public class Builder {
        private var baseUrl: String?
        private var url: String?
        private var queryItems = [String: String]()
        private var authentication: Authentication?
        private var headers = [String: String]()
        private var method: String?
        private var body: Data?
        private var bodyEncodingError: Error?
        private var validStatusCodes: ClosedRange<Int> = 200 ... 299

        public init() {
            authentication = createDefaultAuthentication()
        }

        public func baseUrl(url: String) -> Self {
            baseUrl = url
            return self
        }

        public func get(_ url: String) -> Self {
            self.url = url
            method = "GET"
            return self
        }

        public func patch(_ url: String) -> Self {
            self.url = url
            method = "PATCH"
            return self
        }

        public func patch<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = patch(url)
            encode(body)
            return self
        }

        public func post(_ url: String) -> Self {
            self.url = url
            method = "POST"
            return self
        }

        public func post<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = post(url)
            encode(body)
            return self
        }

        public func post(_ url: String, body: [URLQueryItem]) -> Self {
            _ = post(url)
            encode(body)
            return self
        }

        public func post(_ url: String, body: Data, contentType: String) -> Self {
            _ = post(url)
            self.body = body
            headers["Content-Type"] = contentType
            return self
        }

        public func put(_ url: String) -> Self {
            self.url = url
            method = "PUT"
            return self
        }

        public func put<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = put(url)
            encode(body)
            return self
        }

        public func delete(_ url: String) -> Self {
            self.url = url
            method = "DELETE"
            return self
        }

        public func delete<T: Encodable>(_ url: String, body: T?) -> Self {
            _ = delete(url)
            encode(body)
            return self
        }

        public func query(items: [String: String?]) -> Self {
            items.forEach { name, value in
                queryItems[name] = value
            }

            return self
        }

        public func query(name: String, value: String?) -> Self {
            queryItems[name] = value
            return self
        }

        public func header(name: String, value: String?) -> Self {
            headers[name] = value
            return self
        }

        public func authentication(_ authentication: Authentication?) -> Self {
            self.authentication = authentication
            return self
        }

        public func validate(range: ClosedRange<Int>) -> Self {
            validStatusCodes = range
            return self
        }

        public func build() throws -> NotificareRequest {
            if let error = bodyEncodingError {
                throw error
            }

            let url = try computeCompleteUrl()

            guard let method = method else {
                throw NotificareError.invalidArgument(message: "Provide the HTTP method for the request.")
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body

            // Append all available consumer headers.
            headers.forEach { header, value in
                request.setValue(value, forHTTPHeaderField: header)
            }

            let language = Notificare.shared.device().preferredLanguage
            ?? "\(Locale.current.deviceLanguage())-\(Locale.current.deviceRegion())"

            // Ensure the standard Notificare headers are added.
            request.setValue(language, forHTTPHeaderField: "Accept-Language")
            request.setValue(UIDevice.current.userAgent(sdkVersion: Notificare.SDK_VERSION), forHTTPHeaderField: "User-Agent")
            request.setValue(Notificare.SDK_VERSION, forHTTPHeaderField: "X-Notificare-SDK-Version")
            request.setValue(Bundle.main.applicationVersion, forHTTPHeaderField: "X-Notificare-App-Version")

            // Add application authentication when available
            if let authentication = authentication {
                request.setValue(authentication.encode(), forHTTPHeaderField: "Authorization")
            }

            return NotificareRequest(
                request: request,
                validStatusCodes: validStatusCodes
            )
        }

        public func response(_ completion: @escaping (Result<(response: HTTPURLResponse, data: Data?), Error>) -> Void) {
            do {
                try build().response(completion)
            } catch {
                completion(.failure(error))
            }
        }

        @discardableResult
        public func response() async throws -> (response: HTTPURLResponse, data: Data?) {
            try await withCheckedThrowingContinuation { continuation in
                response { result in
                    continuation.resume(with: result)
                }
            }
        }

        public func responseDecodable<T: Decodable>(_ type: T.Type, _ completion: @escaping (Result<T, Error>) -> Void) {
            do {
                try build().responseDecodable(type, completion)
            } catch {
                completion(.failure(error))
            }
        }

        public func responseDecodable<T: Decodable>(_ type: T.Type) async throws -> T {
            try await withCheckedThrowingContinuation { continuation in
                responseDecodable(type) { result in
                    continuation.resume(with: result)
                }
            }
        }

        // MARK: - Private API

        private func computeCompleteUrl() throws -> URL {
            guard var urlStr = url else {
                throw NotificareError.invalidArgument(message: "Provide a URL for the request.")
            }

            if !urlStr.starts(with: "http://"), !urlStr.starts(with: "https://") {
                guard var baseUrl = baseUrl ?? Notificare.shared.servicesInfo?.hosts.restApi else {
                    throw NotificareError.invalidArgument(message: "Unable to determine the base url for the request.")
                }

                if !baseUrl.starts(with: "http://"), !baseUrl.starts(with: "https://") {
                    baseUrl = "https://\(baseUrl)"
                }

                urlStr = !baseUrl.hasSuffix("/") && !urlStr.hasPrefix("/")
                    ? "\(baseUrl)/\(urlStr)"
                    : "\(baseUrl)\(urlStr)"
            }

            guard var url = URL(string: urlStr) else {
                throw NotificareError.invalidArgument(message: "Invalid url '\(urlStr)'.")
            }

            if !queryItems.isEmpty {
                queryItems.forEach { key, value in
                    url.appendQueryComponent(name: key, value: value)
                }
            }

            return url
        }

        private func createDefaultAuthentication() -> Authentication? {
            guard let applicationKey = Notificare.shared.servicesInfo?.applicationKey,
                  let applicationSecret = Notificare.shared.servicesInfo?.applicationSecret
            else {
                logger.warning("Notificare application authentication not configured.")
                return nil
            }

            return .basic(username: applicationKey, password: applicationSecret)
        }

        private func encode<T: Encodable>(_ body: T?) {
            if let body = body {
                do {
                    self.body = try JSONEncoder.notificare.encode(body)
                    headers["Content-Type"] = "application/json"
                } catch {
                    bodyEncodingError = error
                }
            }
        }

        private func encode(_ body: [URLQueryItem]) {
            let parameters = body.map { item -> String in
                let key = item.name
                let value = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                return "\(key)=\(value ?? "")"
            }

            self.body = parameters.joined(separator: "&").data(using: .utf8)
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        }
    }

    public enum Authentication {
        case basic(username: String, password: String)

        public func encode() -> String {
            switch self {
            case let .basic(username, password):
                let base64encoded = "\(username):\(password)"
                    .data(using: .utf8)!
                    .base64EncodedString()

                return "Basic \(base64encoded)"
            }
        }
    }
}
