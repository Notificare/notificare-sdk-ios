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
import NotificarePushKit
import NotificarePushUIKit
import NotificareScannablesKit
import OSLog
import SwiftUI

private let REQUESTED_LOCATION_ALWAYS_KEY = "re.notifica.geo.capacitor.requested_location_always"

@MainActor
internal class HomeViewModel: NSObject, ObservableObject {
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

    @Published internal  private(set) var viewState: ViewState = .isNotReady
    @Published internal private(set) var userMessages: [UserMessage] = []
    @Published internal private(set) var badge = Notificare.shared.inbox().badge

    // Launch Flow

    @Published internal private(set) var isConfigured = Notificare.shared.isConfigured
    @Published internal private(set) var isReady = Notificare.shared.isReady

    // Notifications

    @Published internal var hasNotificationsAndPermission = Notificare.shared.push().allowedUI && Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var hasNotificationsEnabled = Notificare.shared.push().hasRemoteNotificationsEnabled
    @Published internal private(set) var allowedUi = Notificare.shared.push().allowedUI
    @Published internal private(set) var subscription = Notificare.shared.push().subscription
    @Published internal private(set) var notificationsPermission: NotificationsPermissionStatus? = nil

    // Do not disturb

    @Published internal var hasDndEnabled = false
    @Published internal var startTime = NotificareTime.defaultStart.date
    @Published internal var endTime = NotificareTime.defaultEnd.date

    // Geo

    @Published internal var hasLocationAndPermission = Notificare.shared.geo().hasLocationServicesEnabled
    @Published internal private(set) var hasLocationEnabled = false
    @Published internal private(set) var locationPermission: LocationPermissionStatus? = nil
    @Published internal private(set) var hasBluetoothEnabled = false

    // In app messaging

    @Published internal var hasEvaluateContextOn = false
    @Published internal var hasSuppressedOn = false

    // Device registration

    @Published internal var userId = ""
    @Published internal var userName = ""
    @Published internal private(set) var isDeviceRegistered = false

    // Live Activities

    @Published internal private(set) var coffeeBrewerLiveActivityState: CoffeeBrewerActivityAttributes.BrewingState?

    // Application Info

    @Published internal private(set) var applicationInfo: ApplicationInfo?

    private var cancellables = Set<AnyCancellable>()

    override internal init() {
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
                self?.applicationInfo = self?.getApplicationInfo()
            }
            .store(in: &cancellables)

        // Listening for inbox items and badge updates

        Notificare.shared.inbox().itemsStream
            .sink { items in
                Logger.main.info("Combine publisher inbox update. Total = \(items.count)")
            }
            .store(in: &cancellables)

        Notificare.shared.inbox().badgeStream
            .handleEvents(receiveOutput: { badge in
                Logger.main.info("Combine publisher badge update. Unread = \(badge)")
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$badge)

        // Listening for notification changes (only when has remote notifications enabled)

        Notificare.shared.push().allowedUIStream
            .sink { [weak self] allowedUI in
                self?.checkNotificationsStatus()
                Logger.main.info("Combine publisher allowedUI: \(allowedUI)")
            }
            .store(in: &cancellables)

        Notificare.shared.push().subscriptionStream
            .handleEvents(receiveOutput: { subscription in
                Logger.main.info("Combine publisher subscription: \(String(describing: subscription))")
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$subscription)

        // Load initial stats

        updateStats()

        if #available(iOS 16.1, *), LiveActivitiesController.shared.hasLiveActivityCapabilities {
            monitorLiveActivities()
        }

        applicationInfo = getApplicationInfo()
    }

    internal func updateStats() {
        checkNotificationsStatus()
        checkDndStatus()
        checkLocationStatus()
        checkCurrentDevice()
    }
}

// Launch Flow

extension HomeViewModel {
    internal func notificareLaunch() {
        Logger.main.info("Notificare launch clicked")
        Notificare.shared.launch { _ in }
    }

    internal func notificareUnlaunch() {
        Logger.main.info("Notificare unlaunch clicked")
        Notificare.shared.unlaunch { _ in }
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
                locationPermission = LocationPermissionStatus.always
            } else {
                locationPermission = LocationPermissionStatus.whenInUse
            }
        case .notDetermined:
            locationPermission = LocationPermissionStatus.notDetermined
        case .restricted:
            locationPermission = LocationPermissionStatus.restricted
        case .permanentlyDenied:
            locationPermission = LocationPermissionStatus.permanentlyDenied
        }
    }

    internal func updateLocationServicesStatus(enabled: Bool) {
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

        case .notDetermined:
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

        case .notDetermined:
            Logger.main.info("Location Always is not determined, requesting permission")
            requestLocationPermission(permission: .locationAlways)

        case .granted:
            Logger.main.info("Location Always permission is granted, enabling location updates")
            Notificare.shared.geo().enableLocationUpdates()
        }
    }

    private func checkLocationPermissionStatus(permission: LocationPermissionGroup) -> LocationPermissionGroupStatus {
        if permission == .locationAlways {
            switch authorizationStatus {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_LOCATION_ALWAYS_KEY) ? .permanentlyDenied : .notDetermined
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .notDetermined
            }
        }

        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .notDetermined
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
    internal func updateSuppressedIamStatus(enabled: Bool) {
        //        Logger.main.info("\(enabled ? "Supressing" : "Unsupressing") in app messages, evaluate context is \(hasEvaluateContextOn ? "ON" : "OFF")")
        Notificare.shared.inAppMessaging().setMessagesSuppressed(enabled, evaluateContext: hasEvaluateContextOn)
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

    internal func registerDevice() {
        Logger.main.info("Registering device")

        Task {
            do {
                try await Notificare.shared.device().updateUser(userId: userId, userName: userName.isEmpty ? nil : userName)
                isDeviceRegistered = true
                Logger.main.info("Device registered successfully")

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure)
                )
            }
        }
    }

    internal func cleanDeviceRegistration() {
        Logger.main.info("Registering device as anonymous")

        Task {
            do {
                try await Notificare.shared.device().updateUser(userId: nil, userName: nil)
                isDeviceRegistered = false
                userId = ""
                userName = ""

                userMessages.append(
                    UserMessage(variant: .registerDeviceSuccess)
                )
            } catch {
                Logger.main.error("Failed to registered device as anonymous: \(error)")

                userMessages.append(
                    UserMessage(variant: .registerDeviceFailure)
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

                        case .stale:
                            break

                        @unknown default:
                            Logger.main.warning("Live activity '\(activity.id)' unknown state '\(String(describing: state))'.")
                        }
                    }
                }
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
            case registerDeviceSuccess
            case registerDeviceFailure
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

    internal enum LocationPermissionGroup: CaseIterable {
        case locationWhenInUse
        case locationAlways
        case bluetoothScan
    }

    internal enum LocationPermissionGroupStatus: CaseIterable {
        case notDetermined
        case granted
        case restricted
        case permanentlyDenied
    }

    internal enum LocationPermissionStatus: String, CaseIterable {
        case notDetermined = "permission_status_not_determined"
        case restricted = "permission_status_restricted"
        case permanentlyDenied = "permission_status_permanently_denied"
        case whenInUse = "permission_status_when_in_use"
        case always = "permission_status_always"

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
