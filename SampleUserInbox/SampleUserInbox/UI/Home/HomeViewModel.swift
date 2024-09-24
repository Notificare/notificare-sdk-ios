//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Auth0
import Alamofire
import Combine
import Foundation
import NotificareKit
import NotificarePushKit
import NotificarePushUIKit
import OSLog
import SwiftUI

@MainActor
internal class HomeViewModel: NSObject, ObservableObject {
    @Published internal  private(set) var viewState: ViewState = .isNotReady
    @Published internal private(set) var userMessages: [UserMessage] = []

    // Authentication Flow

    @Published internal private(set) var isLoggedIn = false
    @Published internal private(set) var isDeviceRegistered = false
    @Published internal private(set) var badge = 0

    // Launch Flow

    @Published internal private(set) var isConfigured = Notificare.shared.isConfigured
    @Published internal private(set) var isReady = Notificare.shared.isReady

    // Notifications

    @Published internal var hasNotificationsAndPermission = Notificare.shared.push().allowedUI && Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var hasNotificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var allowedUi = Notificare.shared.push().allowedUI
    @Published internal private(set) var notificationsPermission: NotificationsPermissionStatus? = nil

    // Do not disturb

    @Published internal var hasDndEnabled = false
    @Published internal var startTime = NotificareTime.defaultStart.date
    @Published internal var endTime = NotificareTime.defaultEnd.date

    // Application Info

    @Published internal private(set) var applicationInfo: ApplicationInfo?

    private let notificationCenter = UNUserNotificationCenter.current()
    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    private var cancellables = Set<AnyCancellable>()

    override internal init() {
        super.init()

        // Listening for notificare ready

        NotificationCenter.default
            .publisher(for: .notificareStatus)
            .sink { [weak self] notification in
                guard let ready = notification.userInfo?["ready"] as? Bool else {
                    return
                }

                self?.isReady = ready
                self?.viewState = ready ? .isReady : .isNotReady
                self?.applicationInfo = self?.getApplicationInfo()
            }
            .store(in: &cancellables)

        // Listening for notification changes (only when has remote notifications enabled)

        NotificationCenter.default
            .publisher(for: .notificationSettingsChanged, object: nil)
            .sink { [weak self] _ in
                self?.checkNotificationsStatus()
            }
            .store(in: &cancellables)

        // Listening for push events to update badge

        NotificationCenter.default
            .publisher(for: .notifyInboxUpdate, object: nil)
            .sink { [weak self] _ in
                self?.updateBadge()
            }
            .store(in: &cancellables)

        // Load initial stats

        updateStats()
        startAutoLoginFlow()

        applicationInfo = getApplicationInfo()
    }

    internal func updateStats() {
        checkNotificationsStatus()
        checkDndStatus()
    }
}

// Launch Flow

extension HomeViewModel {
    internal func notificareLaunch() {
        Logger.main.info("Notificare launch clicked")

        Task {
            do {
                try await Notificare.shared.launch()
            } catch {
                Logger.main.error("Notificare.shared.launch failed: \(error).")
            }
        }
    }

    internal func notificareUnlaunch() {
        Logger.main.info("Notificare unlaunch clicked")

        Task {
            do {
                try await Notificare.shared.unlaunch()
                isDeviceRegistered = false
            } catch {
                Logger.main.error("Notificare.shared.launch failed: \(error).")
            }
        }
    }
}

// Notifications

extension HomeViewModel {
    internal func updateNotificationsStatus(enabled: Bool) {
        Logger.main.info("Notifications Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            Logger.main.info("Checking notifications permission")

            Task {
                let status = await checkNotificationsPermissionStatus()

                if status == .permanentlyDenied {
                    Logger.main.info("Notification permission permanently denied, skipping enabling remote notifications")
                    hasNotificationsAndPermission = false

                    return
                }

                if status == .notDetermined {
                    Logger.main.info("Requesting notifications permission")

                    do {
                        let granted = try await notificationCenter.requestAuthorization(options: Notificare.shared.push().authorizationOptions)

                        userMessages.append(
                            UserMessage(variant: .requestNotificationsPermissionSuccess)
                        )

                        switch granted {
                        case true:
                            Logger.main.info("Granted notifications permission")

                        case false:
                            Logger.main.error("Notifications permission request denied, skipping enabling remote notifications")
                            hasNotificationsAndPermission = false

                            return
                        }
                    } catch {
                        Logger.main.error("Failed to request notifications authorization: \(error)")
                        hasNotificationsAndPermission = false

                        userMessages.append(
                            UserMessage(variant: .requestNotificationsPermissionFailure)
                        )
                    }
                }

                Logger.main.info("Enabling remote notifications")

                do {
                    let result = try await Notificare.shared.push().enableRemoteNotifications()
                    Logger.main.info("Successfully enabled remote notifications, result bool: \(result)")

                    userMessages.append(
                        UserMessage(variant: .enableRemoteNotificationsSuccess)
                    )
                } catch {
                    Logger.main.error("Failed to enable remote notifications: \(error)")

                    userMessages.append(
                        UserMessage(variant: .enableRemoteNotificationsFailure)
                    )
                }

                checkNotificationsStatus()
            }
        } else {
            Task {
                Logger.main.info("Disabling remote notifications")
                try await Notificare.shared.push().disableRemoteNotifications()

                checkNotificationsStatus()
            }
        }
    }

    private func checkNotificationsPermissionStatus() async -> (NotificationsPermissionStatus) {
        await withCheckedContinuation { completion in
            UNUserNotificationCenter.current().getNotificationSettings { status in
                var permissionStatus = NotificationsPermissionStatus.denied

                if status.authorizationStatus == .notDetermined {
                    permissionStatus = NotificationsPermissionStatus.notDetermined
                }

                if status.authorizationStatus == .authorized {
                    permissionStatus = NotificationsPermissionStatus.granted
                }

                if status.authorizationStatus == .denied {
                    permissionStatus = NotificationsPermissionStatus.permanentlyDenied
                }

                completion.resume(returning: permissionStatus)
            }
        }
    }

    internal func checkNotificationsStatus() {
        Task {
            let status = await checkNotificationsPermissionStatus()

            hasNotificationsAndPermission = Notificare.shared.push().hasRemoteNotificationsEnabled && status == .granted
            notificationsPermission = status
            hasNotificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled
            allowedUi = Notificare.shared.push().allowedUI
        }
    }
}

// Do Not Disturb

extension HomeViewModel {
    private func checkDndStatus() {
        let dnd = Notificare.shared.device().currentDevice?.dnd
        guard let dnd = dnd else { return }

        startTime = dnd.start.date
        endTime = dnd.end.date
        hasDndEnabled = true
    }

    internal func updateDndStatus(enabled: Bool) {
        Logger.main.info("DnD Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            updateDndTime()
        } else {
            Logger.main.info("Clearing DnD")

            Task {
                do {
                    try await Notificare.shared.device().clearDoNotDisturb()
                    Logger.main.info("DnD cleared successfully")

                    userMessages.append(
                        UserMessage(variant: .clearDoNotDisturbSuccess)
                    )
                } catch {
                    Logger.main.error("Failed to clear DnD: \(error)")

                    userMessages.append(
                        UserMessage(variant: .clearDoNotDisturbFailure)
                    )
                }
            }
        }
    }

    internal func updateDndTime() {
        Logger.main.info("Updating DnD time")

        Task {
            do {
                try await Notificare.shared.device().updateDoNotDisturb(NotificareDoNotDisturb(start: NotificareTime(from: startTime), end: NotificareTime(from: endTime)))
                Logger.main.info("DnD updated successfully")

                userMessages.append(
                    UserMessage(variant: .updateDoNotDisturbSuccess)
                )
            } catch {
                Logger.main.error("Failed to update DnD: \(error)")

                userMessages.append(
                    UserMessage(variant: .updateDoNotDisturbFailure)
                )
            }
        }
    }
}

// Application Info

extension HomeViewModel {
    private func getApplicationInfo() -> ApplicationInfo? {
        guard let application = Notificare.shared.application else {
            return nil
        }

        return ApplicationInfo(
            name: application.name,
            identifier: application.id
        )
    }
}

// User Inbox

extension HomeViewModel {
    internal func startLoginFlow() {
        Task {
            do {
                let credentials = try await loginWithBrowser()
                isLoggedIn = true
                Logger.main.info("Login success.")

                if !credentialsManager.store(credentials: credentials) {
                    Logger.main.error("Failed to store credentials.")
                }

                try await registerDevice(accessToken: credentials.accessToken)
                isDeviceRegistered = true
                Logger.main.info("Register device success.")

                updateBadge()
            } catch {
                Logger.main.error("Login flow failed: \(error)")

                userMessages.append(
                    UserMessage(variant: .clientLoginFlowFailure)
                )
            }
        }
    }

    internal func startLogoutFlow() {
        if !credentialsManager.clear() {
            Logger.main.error("Failed to remove credentials. Skipping logout flow.")
            return
        }

        Task {
            do {
                try await logoutWithBrowser()
                isLoggedIn = false

                Logger.main.info("Successfull logout.")
            } catch {
                Logger.main.error("Logout flow failed: \(error)")

                userMessages.append(
                    UserMessage(variant: .clientLogoutFlowFailure)
                )
            }
        }
    }

    private func startAutoLoginFlow() {
        guard credentialsManager.canRenew() else {
            Logger.main.error("Auto login failed, no valid credentials found. Login required.")
            return
        }

        isLoggedIn = true
        isDeviceRegistered = true
        updateBadge()

        Logger.main.info("Successfull auto login.")
    }

    private func loginWithBrowser() async throws -> Credentials {
        let credentials = try await Auth0
            .webAuth()
            .scope("offline_access")
            .start()

        return credentials
    }

    private func logoutWithBrowser() async throws {
        try await Auth0
            .webAuth()
            .clearSession()
    }

    private func registerDevice(accessToken: String) async throws {
        guard let userInboxClient = SampleUserInboxClient.loadFromPlist(), userInboxClient.isAllDataFilled else {
            throw UserInboxError.missingClientData
        }

        guard let deviceId = Notificare.shared.device().currentDevice?.id else {
            throw UserInboxError.noDeviceIdAvailable
        }

        let response = await AF.request("\(userInboxClient.registerDeviceUrl)/\(deviceId)", method: .put, headers: .authorizationHeader(accessToken: accessToken))
            .validate()
            .serializingString(emptyResponseCodes: [200, 204, 205])
            .response

        if let error = response.error {
            throw error
        }
    }

    private func updateBadge() {
        guard credentialsManager.canRenew() else {
            Logger.main.error("No valid credentials found. Update badge failed.")
            return
        }

        Task {
            do {
                let accessToken = try await credentialsManager.credentials().accessToken

                guard let userInboxClient = SampleUserInboxClient.loadFromPlist(), userInboxClient.isAllDataFilled else {
                    userMessages.append(
                        UserMessage(variant: .updateBadgeFailure)
                    )

                    Logger.main.error("Failed to update badge, missing data in SampleUserInboxClient.")
                    return
                }

                let response = await AF.request(userInboxClient.fetchInboxUrl, method: .get, headers: .authorizationHeader(accessToken: accessToken))
                    .validate()
                    .serializingString()
                    .response

                if let error = response.error {
                    throw error
                }

                let userInboxResponse = try Notificare.shared.userInbox().parseResponse(data: response.data!)
                self.badge = userInboxResponse.unread

                Logger.main.info("Badge updated successfully.")
            } catch {
                userMessages.append(
                    UserMessage(variant: .updateBadgeFailure)
                )

                Logger.main.error("Failed to update badge: \(error)")
            }
        }
    }
}

extension HomeViewModel {
    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal enum ViewState {
        case isNotReady
        case isReady
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant {
            case requestNotificationsPermissionSuccess
            case requestNotificationsPermissionFailure
            case enableRemoteNotificationsSuccess
            case enableRemoteNotificationsFailure
            case clearDoNotDisturbSuccess
            case clearDoNotDisturbFailure
            case updateDoNotDisturbSuccess
            case updateDoNotDisturbFailure
            case clientLoginFlowSuccess
            case clientLoginFlowFailure
            case clientLogoutFlowSuccess
            case clientLogoutFlowFailure
            case updateBadgeSuccess
            case updateBadgeFailure
        }
    }
}

extension HomeViewModel {
    internal enum NotificationsPermissionStatus: String, CaseIterable {
        case notDetermined = "permission_status_not_determined"
        case granted = "permission_status_granted"
        case denied = "permission_status_denied"
        case permanentlyDenied = "permission_status_permanently_denied"

        internal var localized: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    }
}

extension NotificareTime {
    internal init(from date: Date) {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)

        try! self.init(hours: hours, minutes: minutes)
    }

    internal var date: Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date())!
    }

    internal static var defaultStart: NotificareTime {
        try! NotificareTime(hours: 23, minutes: 0)
    }

    internal static var defaultEnd: NotificareTime {
        try! NotificareTime(hours: 8, minutes: 0)
    }
}
