//
// Copyright (c) 2021 Notificare. All rights reserved.
//

public struct NotificareRequest {
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil

        return URLSession(configuration: configuration)
    }()

    private let request: URLRequest
    private let validStatusCodes: ClosedRange<Int>

    public func response(_ completion: @escaping (Result<(response: HTTPURLResponse, data: Data?), Error>) -> Void) {
        NotificareRequest.session.perform(request) { result in
            switch result {
            case .success(let (response, data)):
                guard validStatusCodes.contains(response.statusCode) else {
                    completion(.failure(NotificareNetworkError.validationError(response: response, data: data, validStatusCodes: validStatusCodes)))
                    return
                }

                completion(.success((response, data)))

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
                    let model = try NotificareUtils.jsonDecoder.decode(type, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public class Builder {
        private var baseUrl: String?
        private var url: String?
        private var queryItems = [String: String]()
        private var headers = [String: String]()
        private var method: String?
        private var body: Data?
        private var bodyEncodingError: Error?
        private var validStatusCodes: ClosedRange<Int> = 200 ... 299

        public init() {}

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
                throw NotificareError.generic(message: "Please provide the HTTP method for the request.")
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.httpBody = body

            // Append all available consumer headers.
            headers.forEach { header, value in
                request.setValue(value, forHTTPHeaderField: header)
            }

            // Ensure the standard Notificare headers are added.
            request.setValue(NotificareDefinitions.sdkVersion, forHTTPHeaderField: "X-Notificare-SDK-Version")
            request.setValue(NotificareUtils.applicationVersion, forHTTPHeaderField: "X-Notificare-App-Version")

            // Add application authentication when available
            if let applicationKey = Notificare.shared.servicesInfo?.applicationKey, let applicationSecret = Notificare.shared.servicesInfo?.applicationSecret {
                let base64encoded = "\(applicationKey):\(applicationSecret)"
                    .data(using: .utf8)!
                    .base64EncodedString()

                request.setValue("Basic \(base64encoded)", forHTTPHeaderField: "Authorization")
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

        public func responseDecodable<T: Decodable>(_ type: T.Type, _ completion: @escaping (Result<T, Error>) -> Void) {
            do {
                try build().responseDecodable(type, completion)
            } catch {
                completion(.failure(error))
            }
        }

        // MARK: - Private API

        private func computeCompleteUrl() throws -> URL {
            guard var urlStr = url else {
                throw NotificareError.generic(message: "Please provide the URL for the request.")
            }

            if !urlStr.starts(with: "http://"), !urlStr.starts(with: "https://") {
                guard let baseUrl = baseUrl ?? Notificare.shared.servicesInfo?.services.pushHost else {
                    throw NotificareError.generic(message: "Unable to determine the base url for the request.")
                }

                urlStr = !baseUrl.hasSuffix("/") && !urlStr.hasPrefix("/")
                    ? "\(baseUrl)/\(urlStr)"
                    : "\(baseUrl)\(urlStr)"
            }

            guard var url = URL(string: urlStr) else {
                throw NotificareError.generic(message: "Unable to parse url string '\(urlStr)'.")
            }

            if !queryItems.isEmpty {
                queryItems.forEach { key, value in
                    url.appendQueryComponent(name: key, value: value)
                }
            }

            return url
        }

        private func encode<T: Encodable>(_ body: T?) {
            if let body = body {
                do {
                    self.body = try NotificareUtils.jsonEncoder.encode(body)
                    headers["Content-Type"] = "application/json"
                } catch {
                    bodyEncodingError = error
                }
            }
        }
    }
}
