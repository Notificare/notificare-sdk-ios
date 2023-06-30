//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import ActivityKit
import Combine
import CoreLocation
import Foundation
import NotificareAssetsKit
import NotificareGeoKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificareMonetizeKit
import NotificarePushKit
import NotificarePushUIKit
import NotificareScannablesKit
import OSLog
import SwiftUI

private let REQUESTED_LOCATION_ALWAYS_KEY = "re.notifica.geo.capacitor.requested_location_always"

@MainActor
class HomeViewModel: NSObject, ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    private var requestedPermission: LocationPermissionGroup?
    private var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    @Published private(set) var viewState: ViewState = .isNotReady
    @Published private(set) var userMessages: [UserMessage] = []
    @Published private(set) var badge = Notificare.shared.inbox().badge

    // Launch Flow

    @Published private(set) var isConfigured = Notificare.shared.isConfigured
    @Published private(set) var isReady = Notificare.shared.isReady

    // Notifications

    @Published var hasNotificationsAndPermission = Notificare.shared.push().allowedUI && Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published private(set) var hasNotificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published private(set) var allowedUi = Notificare.shared.push().allowedUI
    @Published private(set) var notificationsPermission = ""

    // Do not disturb

    @Published var hasDndEnabled = false
    @Published var startTime = NotificareTime.defaultStart.date
    @Published var endTime = NotificareTime.defaultEnd.date

    // Geo

    @Published var hasLocationAndPermission = Notificare.shared.geo().hasLocationServicesEnabled
    @Published private(set) var hasLocationEnabled = false
    @Published private(set) var locationPermission = ""
    @Published private(set) var hasBluetoothEnabled = false

    // In app messaging

    @Published var hasEvaluateContextOn = false
    @Published var hasSuppressedOn = false

    // Device registration

    @Published var userId = ""
    @Published var userName = ""
    @Published private(set) var isDeviceRegistered = false

    // Live Activities

    @Published private(set) var coffeeBrewerLiveActivityState: CoffeeBrewerActivityAttributes.BrewingState?

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        locationManager.delegate = self

        // Listening for notificare ready

        NotificationCenter.default
            .publisher(for: .notificareStatus)
            .sink { [weak self] notification in
                guard let ready = notification.userInfo?["ready"] as? Bool else {
                    return
                }

                self?.isReady = ready
                self?.viewState = ready ? .isReady : .isNotReady
            }
            .store(in: &cancellables)

        // Listening for badge updates

        NotificationCenter.default
            .publisher(for: .badgeUpdated, object: nil)
            .sink { [weak self] notification in
                guard let badge = notification.userInfo?["badge"] as? Int else {
                    Logger.main.error("Invalid notification payload.")
                    return
                }

                self?.badge = badge
            }
            .store(in: &cancellables)

        // Listening for notification changes (only when has remote notifications enabled)

        NotificationCenter.default
            .publisher(for: .notificationSettingsChanged, object: nil)
            .sink { [weak self] _ in
                self?.checkNotificationsStatus()
            }
            .store(in: &cancellables)

        // Load initial stats

        updateStats()

        if #available(iOS 16.1, *), LiveActivitiesController.shared.hasLiveActivityCapabilities {
            monitorLiveActivities()
        }
    }

    func updateStats() {
        checkNotificationsStatus()
        checkDndStatus()
        checkLocationStatus()
        checkCurrentDevice()
    }
}

// Launch Flow

extension HomeViewModel {
    func notificareLaunch() {
        Logger.main.info("Notificare launch clicked")
        Notificare.shared.launch()
    }

    func notificareUnlaunch() {
        Logger.main.info("Notificare unlaunch clicked")
        Notificare.shared.unlaunch()
    }
}

// Notifications

extension HomeViewModel {
    func updateNotificationsStatus(enabled: Bool) {
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

                if status == .not_determined {
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
                            UserMessage(variant: .requestNotificationsPermissionFailure(error: error))
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
                        UserMessage(variant: .enableRemoteNotificationsFailure(error: error))
                    )
                }

                checkNotificationsStatus()
            }
        } else {
            Logger.main.info("Disabling remote notifications")
            Notificare.shared.push().disableRemoteNotifications()

            checkNotificationsStatus()
        }
    }

    private func checkNotificationsPermissionStatus() async -> (NotificationsPermissionStatus) {
        await withCheckedContinuation { completion in
            UNUserNotificationCenter.current().getNotificationSettings { status in
                var permissionStatus = NotificationsPermissionStatus.denied

                if status.authorizationStatus == .notDetermined {
                    permissionStatus = NotificationsPermissionStatus.not_determined
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

    func checkNotificationsStatus() {
        Task {
            let status = await checkNotificationsPermissionStatus()

            hasNotificationsAndPermission = Notificare.shared.push().hasRemoteNotificationsEnabled && status == .granted
            notificationsPermission = status.rawValue
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

    func updateDndStatus(enabled: Bool) {
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
                        UserMessage(variant: .clearDoNotDisturbFailure(error: error))
                    )
                }
            }
        }
    }

    func updateDndTime() {
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
                    UserMessage(variant: .updateDoNotDisturbFailure(error: error))
                )
            }
        }
    }
}

// Location

extension HomeViewModel: CLLocationManagerDelegate {
    private func checkLocationStatus() {
        let whenInUse = checkLocationPermissionStatus(permission: .locationWhenInUse)
        let always = checkLocationPermissionStatus(permission: .locationAlways)

        hasLocationAndPermission = whenInUse == .granted && Notificare.shared.geo().hasLocationServicesEnabled
        hasLocationEnabled = Notificare.shared.geo().hasLocationServicesEnabled
        hasBluetoothEnabled = Notificare.shared.geo().hasBluetoothEnabled

        // Check location init

        switch whenInUse {
        case .granted:
            if always == .granted {
                locationPermission = "Always"
            } else {
                locationPermission = "When in Use"
            }
        case .denied:
            locationPermission = "Not Determinated"
        case .restricted:
            locationPermission = "Restricted"
        case .permanentlyDenied:
            locationPermission = "Permanently denied"
        }
    }

    func updateLocationServicesStatus(enabled: Bool) {
        Logger.main.info("Location Toggle switched \(enabled ? "ON" : "OFF")")

        if enabled {
            enableLocationUpdates()
        } else {
            Logger.main.info("Disabling location updates")
            Notificare.shared.geo().disableLocationUpdates()
            checkLocationStatus()
        }
    }

    private func enableLocationUpdates() {
        if checkLocationPermissionStatus(permission: .locationAlways) == .granted {
            Logger.main.info("Location Always is Granted, enabling location updates ")
            Notificare.shared.geo().enableLocationUpdates()
            checkLocationStatus()

            return
        }

        Logger.main.info("Checking location When in Use permission status")
        let whenInUsePermission = checkLocationPermissionStatus(permission: .locationWhenInUse)

        switch whenInUsePermission {
        case .permanentlyDenied, .restricted:
            Logger.main.info("Location When in Use is permanently denied")
            hasLocationAndPermission = false
            return

        case .denied:
            Logger.main.info("Location When in Use is not determined, requesting permission")
            requestLocationPermission(permission: .locationWhenInUse)
            return

        case .granted:
            Logger.main.info("Location When in Use granted, enabling location updates")
            Notificare.shared.geo().enableLocationUpdates()
            checkLocationStatus()
        }

        Logger.main.info("Checking location Always permission status")
        let alwaysPermission = checkLocationPermissionStatus(permission: .locationAlways)

        switch alwaysPermission {
        case .permanentlyDenied, .restricted:
            Logger.main.info("Location Always permission is permanently denied")
            return

        case .denied:
            Logger.main.info("Location Always is not determined, requesting permission")
            requestLocationPermission(permission: .locationAlways)

        case .granted:
            Logger.main.info("Location Always permission is granted, enabling location updates")
            Notificare.shared.geo().enableLocationUpdates()
        }
    }

    private func checkLocationPermissionStatus(permission: LocationPermissionGroup) -> LocationPermissionStatus {
        if permission == .locationAlways {
            switch authorizationStatus {
            case .notDetermined:
                return .denied
            case .restricted:
                return .restricted
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_LOCATION_ALWAYS_KEY) ? .permanentlyDenied : .denied
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .denied
            }
        }

        switch authorizationStatus {
        case .notDetermined:
            return .denied
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .denied
        }
    }

    private func requestLocationPermission(permission: LocationPermissionGroup) {
        requestedPermission = permission

        if permission == .locationWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else if permission == .locationAlways {
            locationManager.requestAlwaysAuthorization()
            UserDefaults.standard.set(true, forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }
    }

    internal func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        onAuthorizationStatusChange(status)
    }

    @available(iOS 14.0, *)
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationStatusChange(manager.authorizationStatus)
    }

    private func onAuthorizationStatusChange(_ authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .notDetermined {
            // When the user changes to "Ask Next Time" via the Settings app.
            UserDefaults.standard.removeObject(forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }

        checkLocationStatus()

        guard let requestedPermission = requestedPermission else {
            return
        }

        let status = checkLocationPermissionStatus(permission: requestedPermission)
        if requestedPermission == .locationWhenInUse {
            if status != .granted {
                Logger.main.info("Location When in Use permission request denied")

                self.requestedPermission = nil
                hasLocationAndPermission = false

                return
            }

            self.requestedPermission = nil
            enableLocationUpdates()
        }

        if requestedPermission == .locationAlways {
            if status == .granted {
                Logger.main.info("Location Always permission request granted, enabling location updates")

                self.requestedPermission = nil
                Notificare.shared.geo().enableLocationUpdates()
            } else {
                Logger.main.info("Location Always permission request denied")
            }
        }
    }
}

// In App Messaging

extension HomeViewModel {
    func updateSuppressedIamStatus(enabled: Bool) {
        Logger.main.info("\(enabled ? "Supressing" : "Unsupressing") in app messages, evaluate context is \(self.hasEvaluateContextOn ? "ON" : "OFF")")
        Notificare.shared.inAppMessaging().setMessagesSuppressed(enabled, evaluateContext: self.hasEvaluateContextOn)
    }
}

// Device Registration

extension HomeViewModel {
    private func checkCurrentDevice() {
        let device = Notificare.shared.device().currentDevice

        userId = device?.userId ?? ""
        userName = device?.userName ?? ""
        isDeviceRegistered = device?.userId != nil
    }

    func registerDevice() {
        Logger.main.info("Registering device")

        Task {
            do {
                try await Notificare.shared.device().register(userId: userId, userName: userName.isEmpty ? nil : userName)
                isDeviceRegistered = true
                Logger.main.info("Device registered successfully")

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure(error: error))
                )
            }
        }
    }

    func cleanDeviceRegistration() {
        Logger.main.info("Registering device as anonymous")

        Task {
            do {
                try await Notificare.shared.device().register(userId: nil, userName: nil)
                isDeviceRegistered = false
                userId = ""
                userName = ""

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device as anonymous: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure(error: error))
                )
            }
        }
    }
}

// Live Activities

extension HomeViewModel {
    @available(iOS 16.1, *)
    private func monitorLiveActivities() {
        withAnimation {
            // Load the initial state.
            coffeeBrewerLiveActivityState = Activity<CoffeeBrewerActivityAttributes>.activities.first?.contentState.state
        }

        Task {
            // Listen to on-going and new Live Activities.
            for await activity in Activity<CoffeeBrewerActivityAttributes>.activityUpdates {
                Task {
                    // Listen to state changes of each activity.
                    for await state in activity.activityStateUpdates {
                        Logger.main.debug("Live activity '\(activity.id)' state = '\(String(describing: state))'")

                        switch activity.activityState {
                        case .active:
                            Task {
                                // Listen to content updates of each active activity.
                                for await state in activity.contentStateUpdates {
                                    withAnimation {
                                        coffeeBrewerLiveActivityState = state.state
                                    }
                                }
                            }

                        case .dismissed, .ended:
                            // Reset the UI controls.
                            coffeeBrewerLiveActivityState = nil

                        @unknown default:
                            Logger.main.warning("Live activity '\(activity.id)' unknown state '\(String(describing: state))'.")
                        }
                    }
                }
            }
        }
    }
}

extension HomeViewModel {
    func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    enum ViewState {
        case isNotReady
        case isReady
    }

    struct UserMessage: Equatable {
        static func == (lhs: UserMessage, rhs: UserMessage) -> Bool {
            lhs.uniqueId == rhs.uniqueId && lhs.variant == rhs.variant
        }

        let uniqueId = UUID().uuidString
        let variant: Variant

        enum Variant: Equatable {
            case requestNotificationsPermissionSuccess
            case requestNotificationsPermissionFailure(error: Error)
            case enableRemoteNotificationsSuccess
            case enableRemoteNotificationsFailure(error: Error)
            case clearDoNotDisturbSuccess
            case clearDoNotDisturbFailure(error: Error)
            case updateDoNotDisturbSuccess
            case updateDoNotDisturbFailure(error: Error)
            case registerDeviceSuccess
            case registerDeviceFailure(error: Error)

            static func == (lhs: Variant, rhs: Variant) -> Bool {
                switch (lhs, rhs) {
                case (.requestNotificationsPermissionSuccess, .requestNotificationsPermissionSuccess),
                     (.enableRemoteNotificationsSuccess, .enableRemoteNotificationsSuccess),
                     (.clearDoNotDisturbSuccess, .clearDoNotDisturbSuccess),
                     (.updateDoNotDisturbSuccess, .updateDoNotDisturbSuccess),
                     (.registerDeviceSuccess, .registerDeviceSuccess):
                    return true

                case let (.requestNotificationsPermissionFailure(lhsError), .requestNotificationsPermissionFailure(rhsError)),
                     let (.enableRemoteNotificationsFailure(lhsError), .enableRemoteNotificationsFailure(rhsError)),
                     let (.clearDoNotDisturbFailure(lhsError), .clearDoNotDisturbFailure(rhsError)),
                     let (.updateDoNotDisturbFailure(lhsError), .updateDoNotDisturbFailure(rhsError)),
                     let (.registerDeviceFailure(lhsError), .registerDeviceFailure(rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription

                default:
                    return false
                }
            }
        }
    }
}

private extension HomeViewModel {
    enum NotificationsPermissionStatus: String, CaseIterable {
        case not_determined = "Not Determined"
        case granted = "Granted"
        case denied = "Denied"
        case permanentlyDenied = "Permanently Denied"
    }

    enum LocationPermissionGroup: String, CaseIterable {
        case locationWhenInUse = "When in Use"
        case locationAlways = "Always"
        case bluetoothScan = "bluetooth_scan"
    }

    enum LocationPermissionStatus: String, CaseIterable {
        case denied = "Denied"
        case granted = "Granted"
        case restricted = "Restricted"
        case permanentlyDenied = "Permanently Denied"
    }
}

extension NotificareTime {
    init(from date: Date) {
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)

        try! self.init(hours: hours, minutes: minutes)
    }

    var date: Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date())!
    }

    static var defaultStart: NotificareTime {
        try! NotificareTime(hours: 23, minutes: 0)
    }

    static var defaultEnd: NotificareTime {
        try! NotificareTime(hours: 8, minutes: 0)
    }
}