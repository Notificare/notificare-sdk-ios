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

    func logout(_ completion: @escaping NotificareCallback<Void>)

    func fetchUserDetails(_ completion: @escaping NotificareCallback<NotificareUser>)

    func changePassword(_ password: String, _ completion: @escaping NotificareCallback<Void>)

    func generatePushEmailAddress(_ completion: @escaping NotificareCallback<NotificareUser>)

    func createAccount(email: String, password: String, name: String?, _ completion: @escaping NotificareCallback<Void>)

    func validateUser(token: String, _ completion: @escaping NotificareCallback<Void>)

    func sendPasswordReset(email: String, _ completion: @escaping NotificareCallback<Void>)

    func resetPassword(_ password: String, token: String, _ completion: @escaping NotificareCallback<Void>)

    func fetchUserPreferences(_ completion: @escaping NotificareCallback<[NotificareUserPreference]>)

    func fetchUserSegments(_ completion: @escaping NotificareCallback<[NotificareUserSegment]>)

    func addUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>)

    func removeUserSegment(_ segment: NotificareUserSegment, _ completion: @escaping NotificareCallback<Void>)

    func addUserSegmentToPreference(_ segment: NotificareUserSegment, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    func addUserSegmentToPreference(option: NotificareUserPreference.Option, to preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    func removeUserSegmentFromPreference(_ segment: NotificareUserSegment, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    func removeUserSegmentFromPreference(option: NotificareUserPreference.Option, from preference: NotificareUserPreference, _ completion: @escaping NotificareCallback<Void>)

    func parsePasswordResetToken(_ url: URL) -> String?

    func parseValidateUserToken(_ url: URL) -> String?
}

public extension NotificareAuthentication {
    func createAccount(email: String, password: String, name: String? = nil, _ completion: @escaping NotificareCallback<Void>) {
        createAccount(email: email, password: password, name: name, completion)
    }
}
