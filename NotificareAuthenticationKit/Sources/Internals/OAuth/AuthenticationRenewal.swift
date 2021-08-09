//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

class AuthenticationRenewal: NotificareRequestAuthenticationDelegate {
    private var performingRenewal = false
    private let authenticationQueue = DispatchQueue(label: "re.notifica.authentication.refresh")
    private var authenticationCallbacks = [NotificareCallback<NotificareRequest.Authentication>]()

    func onRefreshAuthentication(_ completion: @escaping NotificareCallback<NotificareRequest.Authentication>) {
        let canRefresh: Bool = authenticationQueue.sync {
            authenticationCallbacks.append(completion)

            if performingRenewal {
                NotificareLogger.debug("There is an ongoing refresh process. Adding the callback to the queue.")
                return false
            }

            performingRenewal = true
            return true
        }

        if canRefresh {
            refreshCredentials()
        }
    }

    private func refreshCredentials() {
        guard let credentials = LocalStorage.credentials else {
            NotificareLogger.warning("Cannot refresh the credentials when no credentials are present.")
            return
        }

        let payload = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "client_id", value: Notificare.shared.servicesInfo!.applicationKey),
            URLQueryItem(name: "client_secret", value: Notificare.shared.servicesInfo!.applicationSecret),
            URLQueryItem(name: "refresh_token", value: credentials.refreshToken),
        ]

        NotificareLogger.debug("Refreshing user credentials.")
        NotificareRequest.Builder()
            .post("/oauth/token", body: payload)
            .responseDecodable(NotificareInternals.PushAPI.Responses.OAuthResponse.self) { result in
                switch result {
                case let .success(response):
                    NotificareLogger.debug("Done refreshing.")
                    let credentials = Credentials(
                        accessToken: response.access_token,
                        refreshToken: response.refresh_token,
                        expiresIn: response.expires_in
                    )

                    // Store the credentials.
                    LocalStorage.credentials = credentials

                    self.notify(.bearer(token: credentials.accessToken))
                case let .failure(error):
                    self.notify(error)
                }
            }
    }

    private func notify(_ authentication: NotificareRequest.Authentication) {
        authenticationQueue.sync {
            authenticationCallbacks.forEach { $0(.success(authentication)) }
            authenticationCallbacks.removeAll()
            performingRenewal = false
        }
    }

    private func notify(_ error: Error) {
        authenticationQueue.sync {
            authenticationCallbacks.forEach { $0(.failure(error)) }
            authenticationCallbacks.removeAll()
            performingRenewal = false
        }
    }
}
