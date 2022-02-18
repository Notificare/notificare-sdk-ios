//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareAuthentication: AnyObject {
    // MARK: Properties

    var isLoggedIn: Bool { get }

    // MARK: Methods

    func login(email: String, password: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func login(email: String, password: String) async throws

    func logout(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func logout() async throws

    func fetchUserDetails(_ completion: @escaping NotificareCallback<NotificareUser>)

    @available(iOS 13.0, *)
    func fetchUserDetails() async throws -> NotificareUser

    func changePassword(_ password: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func changePassword(_ password: String) async throws

    func generatePushEmailAddress(_ completion: @escaping NotificareCallback<NotificareUser>)

    @available(iOS 13.0, *)
    func generatePushEmailAddress() async throws -> NotificareUser

    func createAccount(email: String, password: String, name: String?, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func createAccount(email: String, password: String, name: String?) async throws

    func validateUser(token: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func validateUser(token: String) async throws

    func sendPasswordReset(email: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func sendPasswordReset(email: String) async throws

    func resetPassword(_ password: String, token: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func resetPassword(_ password: String, token: String) async throws

    func fetchUserPreferences(_ completion: @escaping NotificareCallback<[NotificareUserPreference]>)

    @available(iOS 13.0, *)
    func fetchUserPreferences() async throws -> [NotificareUserPreference]

    func fetchUserSegments(_ completion: @escaping NotificareCallback<[NotificareUserSegment]>)

    @available(iOS 13.0, *)
    func fetchUserSegments() async throws -> [NotificareUserSegment]

    func addUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func addUserSegment(_ segment: NotificareUserSegment) async throws

    func removeUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func removeUserSegment(_ segment: NotificareUserSegment) async throws

    func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference) async throws

    func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference) async throws

    func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference) async throws

    func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference) async throws

    func parsePasswordResetToken(_ url: URL) -> String?

    func parseValidateUserToken(_ url: URL) -> String?
}

public extension NotificareAuthentication {
    func createAccount(email: String, password: String, name: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        createAccount(email: email, password: password, name: name, completion)
    }
}
