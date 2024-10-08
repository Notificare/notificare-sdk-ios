//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

extension URLSession {
    /// Default number of retries to attempt on each `URLRequest` instance. To customize, supply desired value to `perform()`
    public static var maximumNumberOfRetries: Int = 5

    /// Output types
    public typealias DataResult = Result<(response: HTTPURLResponse, data: Data?), NotificareNetworkError>
    public typealias Callback = (DataResult) -> Void

    /// Executes given URLRequest instance, possibly retrying the said number of times. Through `callback` returns either `Data` from the response or `NetworkError` instance.
    /// If any authentication needs to be done, it's handled internally by this methods and its derivatives.
    /// - Parameters:
    ///   - urlRequest: URLRequest instance to execute.
    ///   - maxRetries: Number of automatic retries (default is 5).
    ///   - callback: Closure to return the result of the request's execution.
    public func perform(_ urlRequest: URLRequest,
                        maxRetries: Int = URLSession.maximumNumberOfRetries,
                        allowEmptyData: Bool = false,
                        callback: @escaping Callback)
    {
        if maxRetries <= 0 {
            fatalError("maxRetries must be 1 or larger.")
        }

        let networkRequest = NetworkRequest(urlRequest, 0, maxRetries, allowEmptyData, callback)
        authenticate(networkRequest)
    }
}

extension URLSession {
    /// Helper type which groups `URLRequest` (input), `Callback` from the caller (output)
    /// along with helpful processing properties, like number of retries.
    private typealias NetworkRequest = (
        // swiftlint:disable:previous large_tuple
        urlRequest: URLRequest,
        currentRetries: Int,
        maxRetries: Int,
        allowEmptyData: Bool,
        callback: Callback
    )

    /// Extra-step where `URLRequest`'s authorization should be handled, before actually performing the URLRequest in `execute()`
    private func authenticate(_ networkRequest: NetworkRequest) {
        let currentRetries = networkRequest.currentRetries
        let maxRetries = networkRequest.maxRetries
        let callback = networkRequest.callback

        if currentRetries >= maxRetries {
            // Too many unsuccessful attempts
            DispatchQueue.main.async {
                callback(.failure(.inaccessible))
            }
            return
        }

        //    NOTE: this is the place to handle OAuth2
        //    or some other form of URLRequest‘s authorization
        //    now execute the request
        execute(networkRequest)
    }

    ///    Creates the instance of `URLSessionDataTask`, performs it then lightly processes the response before calling `validate`.
    private func execute(_ networkRequest: NetworkRequest) {
        let urlRequest = networkRequest.urlRequest

        let task = dataTask(with: urlRequest) { [unowned self] data, urlResponse, error in
            let dataResult = process(data, urlResponse, error, for: networkRequest)
            validate(dataResult, for: networkRequest)
        }

        task.resume()
    }

    ///    Process results of `URLSessionDataTask` and converts it into `DataResult` instance
    private func process(_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?, for _: NetworkRequest) -> DataResult {
        if let urlError = error as? URLError {
            return .failure(NotificareNetworkError.urlError(urlError))
        } else if let otherError = error {
            return .failure(NotificareNetworkError.genericError(otherError))
        }

        guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
            if let urlResponse = urlResponse {
                return .failure(NotificareNetworkError.invalidResponseType(urlResponse))
            } else {
                return .failure(NotificareNetworkError.noResponse)
            }
        }

//        if httpURLResponse.statusCode >= 400 {
//            return .failure(NotificareNetworkError.endpointError(httpURLResponse, data))
//        }
//
//        guard let data = data, !data.isEmpty else {
//            if allowEmptyData {
//                return .success(Data())
//            }
//
//            return .failure(NotificareNetworkError.noResponseData(httpURLResponse))
//        }

        return .success((response: httpURLResponse, data: data))
    }

    ///    Checks the result of URLSessionDataTask and if there were errors, should the URLRequest be retried.
    private func validate(_ result: DataResult, for networkRequest: NetworkRequest) {
        let callback = networkRequest.callback

        switch result {
        case .success:
            break

        case let .failure(networkError):
            switch networkError {
            case .inaccessible:
                //    too many failed network calls
                break

            default:
                if networkError.shouldRetry {
                    //    update retries count and
                    var newRequest = networkRequest
                    newRequest.currentRetries += 1
                    //    try again, going through authentication again
                    //    (since it's quite possible that Auth token or whatever has expired)
                    authenticate(newRequest)
                    return
                }
            }
        }

        DispatchQueue.main.async {
            callback(result)
        }
    }
}
