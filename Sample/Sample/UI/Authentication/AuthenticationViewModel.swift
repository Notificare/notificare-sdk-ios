//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareAuthenticationKit
import NotificareKit
import OSLog

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var currentUser: NotificareUser?

    @Published var newUserEmail = ""
    @Published var newUserPassword = ""
    @Published var newUserName = ""

    @Published var validateUserToken = ""

    @Published var loginEmail = ""
    @Published var loginPassword = ""

    @Published var sendPasswordResetEmail = ""

    @Published var resetPasswordNewPassword = ""
    @Published var resetPasswordToken = ""

    @Published var changePasswordNewPassword = ""

    @Published private(set) var fetchedSegments = [NotificareUserSegment]()

    @Published private(set) var fetchedPreferences = [NotificareUserPreference]()
    @Published private(set) var preferenceOptions = [NotificareUserPreference.Option]()
    @Published var selectedPreferenceId = ""
    @Published var selectedOptionIndex = 0

    init() {
        fetchCurentUser()
        fetchUserSegments()
        fetchUserPreferences()
    }

    private func fetchCurentUser() {
        Logger.main.info("-----> Fetching current user <-----")

        if !Notificare.shared.authentication().isLoggedIn {
            Logger.main.info("-----> Skipping fetch current user, not logged in <-----")
            return
        }

        Task {
            do {
                let user = try await Notificare.shared.authentication().fetchUserDetails()
                Logger.main.info("-----> Fetched current user successfully <-----")
                currentUser = user
            } catch {
                print("-----> Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }

    func fetchUserSegments() {
        Logger.main.info("-----> Fetching user segments <-----")

        Task {
            do {
                let segments = try await Notificare.shared.authentication().fetchUserSegments()
                Logger.main.info("-----> Fetched user segments successfully <-----")
                fetchedSegments = segments
            } catch {
                print("-----> Failed to fetch user details: \(error.localizedDescription)")
            }
        }
    }

    private func fetchUserPreferences() {
        Logger.main.info("-----> Fetching user preferences <-----")

        if !Notificare.shared.authentication().isLoggedIn {
            Logger.main.info("-----> Skipping fetch user preferences, not logged in <-----")
            return
        }

        Task {
            do {
                let preferences = try await Notificare.shared.authentication().fetchUserPreferences()
                Logger.main.info("-----> Fetced user preferences successfully <-----")
                fetchedPreferences = preferences
                selectedPreferenceId = preferences[0].id
                preferenceOptions = preferences[0].options
            } catch {
                Logger.main.error("Failed to fetch user preferences: \(error.localizedDescription)")
            }
        }
    }

    func registerNewUser() {
        Logger.main.info("-----> Register user clicked <-----")

        let name = newUserName.isEmpty ? nil : newUserName

        Task {
            do {
                try await Notificare.shared.authentication().createAccount(email: newUserEmail, password: newUserPassword, name: name)
                Logger.main.info("-----> New user account created successfully <-----")
            } catch {
                Logger.main.error("Failed to create new user account: \(error.localizedDescription)")
            }

            newUserEmail = ""
            newUserPassword = ""
            newUserName = ""
        }
    }

    func validateUser() {
        Logger.main.info("-----> Validate user clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().validateUser(token: validateUserToken)
                Logger.main.info("-----> User validated successfully <-----")
                validateUserToken = ""
            } catch {
                Logger.main.error("Failed to validates user: \(error.localizedDescription)")
            }
        }
    }

    func login() {
        Logger.main.info("-----> Login clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().login(email: loginEmail, password: loginPassword)
                Logger.main.info("-----> Login successfully <-----")
                loginEmail = ""
                loginPassword = ""
                fetchCurentUser()
                fetchUserPreferences()
            } catch {
                Logger.main.error("Failed to login: \(error.localizedDescription)")
            }
        }
    }

    func logout() {
        Logger.main.info("-----> Logout clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().logout()
                Logger.main.info("-----> Logout successfully <-----")
                currentUser = nil
            } catch {
                Logger.main.error("Failed to logout: \(error.localizedDescription)")
            }
        }
    }

    func sendPasswordReset() {
        Logger.main.info("-----> Send password reset clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().sendPasswordReset(email: sendPasswordResetEmail)
                Logger.main.info("-----> Password reset sent seccessfully to email <-----")
                sendPasswordResetEmail = ""
            } catch {
                Logger.main.error("Failed to send password reset to email: \(error.localizedDescription)")
            }
        }
    }

    func resetPassword() {
        Logger.main.info("-----> Reset password clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().resetPassword(resetPasswordNewPassword, token: resetPasswordToken)
                Logger.main.info("-----> Password did reset seccessfully <-----")
                resetPasswordNewPassword = ""
                resetPasswordToken = ""
            } catch {
                Logger.main.error("Failed to reset password: \(error.localizedDescription)")
            }
        }
    }

    func changePassword() {
        Logger.main.info("-----> Change password clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().changePassword(changePasswordNewPassword)
                Logger.main.info("-----> Password changed seccessfully <-----")
                changePasswordNewPassword = ""
            } catch {
                Logger.main.error("Failed to change password: \(error.localizedDescription)")
            }
        }
    }

    func addUserSegment(segment: NotificareUserSegment) {
        Logger.main.info("-----> Add user segment clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().addUserSegment(segment)
                Logger.main.info("-----> Segment added seccessfully <-----")
                fetchCurentUser()
            } catch {
                Logger.main.error("Failed to add segment: \(error.localizedDescription)")
            }
        }
    }

    func removeUserSegment(segment: NotificareUserSegment) {
        Logger.main.info("-----> Remove user segment clicked <-----")

        Task {
            do {
                try await Notificare.shared.authentication().removeUserSegment(segment)
                Logger.main.info("-----> Segment removed seccessfully <-----")
                fetchCurentUser()
            } catch {
                Logger.main.error("Failed to remove segment: \(error.localizedDescription)")
            }
        }
    }

    func updatePreferenceOptions() {
        guard let preference = (fetchedPreferences.first { $0.id == selectedPreferenceId }) else {
            return
        }

        preferenceOptions = preference.options
    }

    func addUserSegmentToPreference() {
        Logger.main.info("-----> Add user segment to preference clicked <-----")
        guard let preference = (fetchedPreferences.first { $0.id == selectedPreferenceId }) else {
            return
        }

        let option = preference.options[selectedOptionIndex]

        Task {
            do {
                try await Notificare.shared.authentication().addUserSegmentToPreference(option: option, to: preference)
                Logger.main.info("-----> Added user segment to preference successfully <-----")
                fetchCurentUser()
            } catch {
                Logger.main.error("Failed to add user segment to preference: \(error.localizedDescription)")
            }
        }
    }

    func removeUserSegmentFromPreference() {
        Logger.main.info("-----> Remove user segment from preference clicked <-----")

        guard let preference = (fetchedPreferences.first { $0.id == selectedPreferenceId }) else {
            return
        }

        let option = preference.options[selectedOptionIndex]

        Task {
            do {
                try await Notificare.shared.authentication().removeUserSegmentFromPreference(option: option, from: preference)
                Logger.main.info("-----> Removed user segment from preference successfully <-----")
                fetchCurentUser()
            } catch {
                Logger.main.error("Failed to remove user segment from preference: \(error.localizedDescription)")
            }
        }
    }
}
