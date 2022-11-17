//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

internal class NotificareAuthenticationImpl: NSObject, NotificareModule, NotificareAuthentication {
    private let authenticationRenewal = AuthenticationRenewal()

    // MARK: - Notificare Module

    static let instance = NotificareAuthenticationImpl()

    func migrate() {
        if let account = MigrationUtils.getLegacyCredentials() {
            LocalStorage.credentials = Credentials(
                accessToken: account.accessToken.accessToken,
                refreshToken: account.accessToken.refreshToken,
                expiresIn: 0
            )

            MigrationUtils.removeLegacyCredentials()
        }
    }

    // MARK: - Notificare Authentication

    var isLoggedIn: Bool {
        LocalStorage.credentials != nil
    }

    func login(email: String, password: String, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        let device = Notificare.shared.device().currentDevice!

        let payload = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "client_id", value: Notificare.shared.servicesInfo!.applicationKey),
            URLQueryItem(name: "client_secret", value: Notificare.shared.servicesInfo!.applicationSecret),
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password),
        ]

        NotificareLogger.debug("Logging in the user.")
        NotificareRequest.Builder()
            .post("/oauth/token", body: payload)
            .responseDecodable(NotificareInternals.PushAPI.Responses.OAuthResponse.self) { result in
                switch result {
                case let .success(response):
                    NotificareLogger.debug("Registering the device with the user details.")
                    Notificare.shared.device().register(
                        userId: email,
                        userName: device.userName // TODO: consider fetching the profile and sync the user name in the cached device.
                    ) { result in
                        switch result {
                        case .success:
                            // Store the credentials.
                            LocalStorage.credentials = Credentials(
                                accessToken: response.access_token,
                                refreshToken: response.refresh_token,
                                expiresIn: response.expires_in
                            )

                            Notificare.shared.events().logUserLogin { _ in }
                            completion(.success(()))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func login(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            login(email: email, password: password) { result in
                continuation.resume(with: result)
            }
        }
    }

    func logout(_ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let device = Notificare.shared.device().currentDevice!

        NotificareLogger.debug("Removing user from the device.")
        NotificareRequest.Builder()
            .delete("/device/\(device.id)/user")
            .response { result in
                switch result {
                case .success:
                    NotificareLogger.debug("Removing stored credentials.")
                    LocalStorage.credentials = nil

                    NotificareLogger.debug("Registering device as anonymous.")
                    Notificare.shared.device().register(userId: nil, userName: nil) { result in
                        switch result {
                        case .success:
                            Notificare.shared.events().logUserLogout { _ in }
                            completion(.success(()))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }

                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func logout() async throws {
        try await withCheckedThrowingContinuation { continuation in
            logout { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchUserDetails(_ completion: @escaping NotificareCallback<NotificareUser>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .get("/user/me")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserDetailsResponse.self) { result in
                switch result {
                case let .success(response):
                    Notificare.shared.events().logFetchUserDetails { _ in }
                    completion(.success(response.user.toModel()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchUserDetails() async throws -> NotificareUser {
        try await withCheckedThrowingContinuation { continuation in
            fetchUserDetails { result in
                continuation.resume(with: result)
            }
        }
    }

    func changePassword(_ password: String, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let credentials = LocalStorage.credentials!
        let payload = NotificareInternals.PushAPI.Payloads.ChangePassword(
            password: password
        )

        NotificareRequest.Builder()
            .put("/user/changepassword", body: payload)
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .response { result in
                switch result {
                case .success:
                    Notificare.shared.events().logChangePassword { _ in }
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func changePassword(_ password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            changePassword(password) { result in
                continuation.resume(with: result)
            }
        }
    }

    func generatePushEmailAddress(_ completion: @escaping NotificareCallback<NotificareUser>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .put("/user/generatetoken/me")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .responseDecodable(NotificareInternals.PushAPI.Responses.UserDetailsResponse.self) { result in
                switch result {
                case let .success(response):
                    Notificare.shared.events().logGeneratePushEmailAddress { _ in }
                    completion(.success(response.user.toModel()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func generatePushEmailAddress() async throws -> NotificareUser {
        try await withCheckedThrowingContinuation { continuation in
            generatePushEmailAddress { result in
                continuation.resume(with: result)
            }
        }
    }

    func createAccount(email: String, password: String, name: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.CreateAccount(
            email: email,
            password: password,
            name: name
        )

        NotificareRequest.Builder()
            .post("/user", body: payload)
            .response { result in
                switch result {
                case .success:
                    Notificare.shared.events().logCreateUserAccount { _ in }
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func createAccount(email: String, password: String, name: String?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            createAccount(email: email, password: password, name: name) { result in
                continuation.resume(with: result)
            }
        }
    }

    func validateUser(token: String, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        NotificareRequest.Builder()
            .post("/user/validate/\(token)")
            .response { result in
                switch result {
                case .success:
                    Notificare.shared.events().logValidateUser { _ in }
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func validateUser(token: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            validateUser(token: token) { result in
                continuation.resume(with: result)
            }
        }
    }

    func sendPasswordReset(email: String, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.SendPasswordReset(
            email: email
        )

        NotificareRequest.Builder()
            .put("/user/sendpassword", body: payload)
            .response { result in
                switch result {
                case .success:
                    Notificare.shared.events().logSendPasswordReset { _ in }
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func sendPasswordReset(email: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            sendPasswordReset(email: email) { result in
                continuation.resume(with: result)
            }
        }
    }

    func resetPassword(_ password: String, token: String, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        let payload = NotificareInternals.PushAPI.Payloads.ResetPassword(
            password: password
        )

        NotificareRequest.Builder()
            .put("/user/resetpassword/\(token)", body: payload)
            .response { result in
                switch result {
                case .success:
                    Notificare.shared.events().logResetPassword { _ in }
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func resetPassword(_ password: String, token: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            resetPassword(password, token: token) { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchUserPreferences(_ completion: @escaping NotificareCallback<[NotificareUserPreference]>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        fetchUserDetails { result in
            switch result {
            case let .success(user):
                NotificareRequest.Builder()
                    .get("/userpreference")
                    .responseDecodable(NotificareInternals.PushAPI.Responses.FetchUserPreferencesResponse.self) { result in
                        switch result {
                        case let .success(response):
                            let preferences = response
                                .userPreferences
                                .compactMap { try? $0.toModel(user: user) }

                            completion(.success(preferences))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    @available(iOS 13.0, *)
    func fetchUserPreferences() async throws -> [NotificareUserPreference] {
        try await withCheckedThrowingContinuation { continuation in
            fetchUserPreferences { result in
                continuation.resume(with: result)
            }
        }
    }

    func fetchUserSegments(_ completion: @escaping NotificareCallback<[NotificareUserSegment]>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        NotificareRequest.Builder()
            .get("/usersegment/userselectable")
            .responseDecodable(NotificareInternals.PushAPI.Responses.FetchUserSegmentsResponse.self) { result in
                switch result {
                case let .success(response):
                    let segments = response
                        .userSegments
                        .map { $0.toModel() }

                    completion(.success(segments))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func fetchUserSegments() async throws -> [NotificareUserSegment] {
        try await withCheckedThrowingContinuation { continuation in
            fetchUserSegments { result in
                continuation.resume(with: result)
            }
        }
    }

    func addUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .put("/user/me/add/\(segment.id)")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func addUserSegment(_ segment: NotificareUserSegment) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addUserSegment(segment) { result in
                continuation.resume(with: result)
            }
        }
    }

    func removeUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .put("/user/me/remove/\(segment.id)")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    @available(iOS 13.0, *)
    func removeUserSegment(_ segment: NotificareUserSegment) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeUserSegment(segment) { result in
                continuation.resume(with: result)
            }
        }
    }

    func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        addUserSegmentToPreference(segmentId: segment.id, to: preference, completion)
    }

    @available(iOS 13.0, *)
    func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addUserSegmentToPreference(segment, to: preference) { result in
                continuation.resume(with: result)
            }
        }
    }

    func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        addUserSegmentToPreference(segmentId: option.segmentId, to: preference, completion)
    }

    @available(iOS 13.0, *)
    func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference) async throws {
        try await withCheckedThrowingContinuation { continuation in
            addUserSegmentToPreference(option: option, to: preference) { result in
                continuation.resume(with: result)
            }
        }
    }

    func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        removeUserSegmentFromPreference(segmentId: segment.id, from: preference, completion)
    }

    @available(iOS 13.0, *)
    func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeUserSegmentFromPreference(segment, from: preference) { result in
                continuation.resume(with: result)
            }
        }
    }

    func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        removeUserSegmentFromPreference(segmentId: option.segmentId, from: preference, completion)
    }

    @available(iOS 13.0, *)
    func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference) async throws {
        try await withCheckedThrowingContinuation { continuation in
            removeUserSegmentFromPreference(option: option, from: preference) { result in
                continuation.resume(with: result)
            }
        }
    }

    func parsePasswordResetToken(_ url: URL) -> String? {
        guard
            let application = Notificare.shared.application,
            let appLinksDomain = Notificare.shared.servicesInfo?.services.appLinksDomain,
            url.host == "\(application.id).\(appLinksDomain)",
            url.pathComponents.count >= 4,
            url.pathComponents[1] == "oauth",
            url.pathComponents[2] == "resetpassword"
        else {
            return nil
        }

        return url.pathComponents[3]
    }

    func parseValidateUserToken(_ url: URL) -> String? {
        guard
            let application = Notificare.shared.application,
            let appLinksDomain = Notificare.shared.servicesInfo?.services.appLinksDomain,
            url.host == "\(application.id).\(appLinksDomain)",
            url.pathComponents.count >= 4,
            url.pathComponents[1] == "oauth",
            url.pathComponents[2] == "validate"
        else {
            return nil
        }

        return url.pathComponents[3]
    }

    // MARK: - Private API

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.oauth2.rawValue] == true else {
            NotificareLogger.warning("Notificare authentication functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.oauth2.rawValue)
        }
    }

    private func checkUserLoggedInPrerequisite() throws {
        guard isLoggedIn else {
            NotificareLogger.warning("The user is not logged in.")
            throw NotificareAuthenticationError.userNotLoggedIn
        }
    }

    private func addUserSegmentToPreference(segmentId: String, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        guard preference.options.contains(where: { $0.segmentId == segmentId }) else {
            completion(.failure(NotificareAuthenticationError.invalidPreferenceSegment))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .put("/user/me/add/\(segmentId)/preference/\(preference.id)")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    private func removeUserSegmentFromPreference(segmentId: String, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
            try checkUserLoggedInPrerequisite()
        } catch {
            completion(.failure(error))
            return
        }

        guard preference.options.contains(where: { $0.segmentId == segmentId }) else {
            completion(.failure(NotificareAuthenticationError.invalidPreferenceSegment))
            return
        }

        let credentials = LocalStorage.credentials!

        NotificareRequest.Builder()
            .put("/user/me/remove/\(segmentId)/preference/\(preference.id)")
            .authentication(.bearer(token: credentials.accessToken))
            .authenticationDelegate(authenticationRenewal)
            .response { result in
                switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}
