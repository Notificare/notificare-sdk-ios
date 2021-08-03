//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public class NotificareAuthentication: NSObject, NotificareModule {
    public static let shared = NotificareAuthentication()

    // MARK: - Notificare Module

    public static func configure() {}

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    // MARK: - Public API

    public var isLoggedIn: Bool {
        true
    }

    public func login(email: String, password: String, _ completion: @escaping NotificareCallback<Void>) {
        _ = email
        _ = password
        _ = completion
    }

    public func logout(_ completion: @escaping NotificareCallback<Void>) {
        _ = completion
    }

    public func fetchUserDetails(_ completion: @escaping NotificareCallback<NotificareUser>) {
        _ = completion
    }

    public func changePassword(_ password: String, _ completion: @escaping NotificareCallback<Void>) {
        _ = password
        _ = completion
    }

    public func generatePushEmailAddress(_ completion: @escaping NotificareCallback<NotificareUser>) {
        _ = completion
    }

    public func createAccount(email: String, password: String, name: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        _ = email
        _ = password
        _ = name
        _ = completion
    }

    public func validateUser(token: String, _ completion: @escaping NotificareCallback<Void>) {
        _ = token
        _ = completion
    }

    public func sendPasswordReset(email: String, _ completion: @escaping NotificareCallback<Void>) {
        _ = email
        _ = completion
    }

    public func resetPassword(_ password: String, token: String, _ completion: @escaping NotificareCallback<Void>) {
        _ = password
        _ = token
        _ = completion
    }

    public func fetchUserPreferences(_ completion: @escaping NotificareCallback<[NotificareUserPreference]>) {
        _ = completion
    }

    public func fetchUserSegments(_ completion: @escaping NotificareCallback<Void>) {
        _ = completion
    }

    public func addUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>) {
        _ = segment
        _ = completion
    }

    public func removeUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>) {
        _ = segment
        _ = completion
    }

    public func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = segment
        _ = preference
        _ = completion
    }

    public func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = option
        _ = preference
        _ = completion
    }

    public func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = segment
        _ = preference
        _ = completion
    }

    public func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = option
        _ = preference
        _ = completion
    }

    public func parsePasswordResetToken(_ url: URL) -> String? {
        _ = url
        return nil
    }

    public func parseValidateUserToken(_ url: URL) -> String? {
        _ = url
        return nil
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
        
        guard application.services["oauth2"] == true else {
            NotificareLogger.warning("Notificare authentication functionality is not enabled.")
            throw NotificareError.serviceUnavailable(module: "oauth2")
        }
    }

    private func checkUserLoggedInPrerequisite() throws {
        guard isLoggedIn else {
            NotificareLogger.warning("The user is not logged in.")
            throw NotificareAuthenticationError.userNotLoggedIn
        }
    }

    private func addUserSegmentToPreference(segmentId: String, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = segmentId
        _ = preference
        _ = completion
    }

    private func removeUserSegmentFromPreference(segmentId: String, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>) {
        _ = segmentId
        _ = preference
        _ = completion
    }
}

public enum NotificareAuthenticationError: Error {
    case userNotLoggedIn
}
