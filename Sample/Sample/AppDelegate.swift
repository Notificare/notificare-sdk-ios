//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import ActivityKit
import CoreLocation
import Foundation
import NotificareGeoKit
import NotificareInAppMessagingKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificareMonetizeKit
import NotificarePushKit
import NotificarePushUIKit
import NotificareScannablesKit
import OSLog
import StoreKit
import SwiftUI
import UIKit

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal var window: UIWindow?

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        // Atlantis.start()

        if #available(iOS 14.0, *) {
            Notificare.shared.push().presentationOptions = [.banner, .badge, .sound]
        } else {
            Notificare.shared.push().presentationOptions = [.alert, .badge, .sound]
        }

        Notificare.shared.delegate = self
        Notificare.shared.push().delegate = self
        Notificare.shared.pushUI().delegate = self
        Notificare.shared.inAppMessaging().delegate = self
        Notificare.shared.inbox().delegate = self
        Notificare.shared.geo().delegate = self
        Notificare.shared.monetize().delegate = self
        Notificare.shared.scannables().delegate = self

        Notificare.shared.launch()

        if #available(iOS 16.1, *) {
            LiveActivitiesController.shared.startMonitoring()
        }

        return true
    }

    internal func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {}

    internal func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    internal func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}
}

extension AppDelegate: NotificareDelegate {
    internal func notificare(_: Notificare, onReady _: NotificareApplication) {
        Logger.main.info("Notificare finished launching.")

        registerUser()

        NotificationCenter.default.post(
            name: .notificareStatus,
            object: nil,
            userInfo: ["ready": true]
        )
    }

    internal func notificareDidUnlaunch(_: Notificare) {
        Logger.main.info("Notificare finished un-launching.")

        NotificationCenter.default.post(
            name: .notificareStatus,
            object: nil,
            userInfo: ["ready": false]
        )
    }

    internal func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        Logger.main.info("Notificare: device registered: \(String(describing: device))")
    }

    private func registerUser() {
        guard let user = SampleUser.loadFromPlist() else {
            return
        }

        let userId = user.userId.isEmpty ? nil : user.userId
        let userName = user.userName.isEmpty ? nil : user.userName

        Task {
            do {
                Logger.main.info("Registering device")
                try await Notificare.shared.device().register(userId: userId, userName: userName)
                Logger.main.info("Device registered successfully")
            } catch {
                Logger.main.error("Failed to registered device: \(error)")
            }
        }
    }
}

extension AppDelegate: NotificarePushDelegate {
    internal func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.main.error("Notificare: failed to register for remote notifications: \(error)")
    }

    internal func notificare(_: NotificarePush, didChangeNotificationSettings allowedUI: Bool) {
        Logger.main.info("Notificare: notification settings changed: \(allowedUI)")

        NotificationCenter.default.post(
            name: .notificationSettingsChanged,
            object: nil
        )
    }

    internal func notificare(_: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification) {
        Logger.main.info("Notificare: received a system notification: \(String(describing: notification))")
    }

    internal func notificare(_: NotificarePush, didReceiveNotification notification: NotificareNotification, deliveryMechanism: NotificareNotificationDeliveryMechanism) {
        Logger.main.info("Notificare: received a notification: \(String(describing: notification))")
        Logger.main.info("Notificare: received notification delivery mechanism: \(deliveryMechanism.rawValue)")
    }

    internal func notificare(_: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        Logger.main.info("Notificare: received an unknown notification: \(userInfo)")
    }

    internal func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {
        Logger.main.info("Notificare: should open notification settings")
    }

    internal func notificare(_: NotificarePush, didOpenNotification notification: NotificareNotification) {
        UIApplication.shared.present(notification)
    }

    internal func notificare(_: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        guard let rootViewController = window?.rootViewController else {
            return
        }

        //        guard let scene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first ?? UIApplication.shared.connectedScenes.first,
        //              let window = (scene.delegate as! UIWindowSceneDelegate).window!,
        //              let rootViewController = window.rootViewController
        //        else {
        //            return
        //        }

        Notificare.shared.pushUI().presentAction(action, for: notification, in: rootViewController)
    }

    internal func notificare(_: NotificarePush, didOpenUnknownNotification _: [AnyHashable: Any]) {
        Logger.main.info("Notificare: opened unknown notification")
    }

    internal func notificare(_: NotificarePush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {
        Logger.main.info("Notificare: opened unknown action")
    }
}

extension AppDelegate: NotificarePushUIDelegate {
    internal func notificare(_: NotificarePushUI, willPresentNotification notification: NotificareNotification) {
        Logger.main.info("Notificare: will present notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didPresentNotification notification: NotificareNotification) {
        Logger.main.info("Notificare: did present notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification) {
        Logger.main.error("Notificare: did fail to present notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification) {
        Logger.main.info("Notificare: did finish presenting notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification) {
        Logger.main.info("Notificare: did click url '\(url)' in notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        Logger.main.info("Notificare: will execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        Logger.main.info("Notificare: did execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        Logger.main.info("Notificare: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error _: Error?) {
        Logger.main.error("Notificare: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }

    internal func notificare(_: NotificarePushUI, didReceiveCustomAction _: URL, in _: NotificareNotification.Action, for _: NotificareNotification) {
        //
    }
}

extension AppDelegate: NotificareInboxDelegate {
    internal func notificare(_: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        Logger.main.info("Inbox has loaded. Total = \(items.count)")

        NotificationCenter.default.post(
            name: .inboxUpdated,
            object: nil,
            userInfo: ["items": items]
        )
    }

    internal func notificare(_: NotificareInbox, didUpdateBadge badge: Int) {
        Logger.main.info("Badge update. Unread = \(badge)")

        NotificationCenter.default.post(
            name: .badgeUpdated,
            object: nil,
            userInfo: ["badge": badge]
        )
    }
}

extension AppDelegate: NotificareGeoDelegate {
    internal func notificare(_: NotificareGeo, didUpdateLocations locations: [NotificareLocation]) {
        Logger.main.info("Locations updated = \(locations)")
    }

    internal func notificare(_: NotificareGeo, didFailWith error: Error) {
        Logger.main.error("Location services failed = \(error)")
    }

    internal func notificare(_: NotificareGeo, didStartMonitoringFor region: NotificareRegion) {
        Logger.main.info("Started monitoring region = \(region.name)")
    }

    internal func notificare(_: NotificareGeo, didStartMonitoringFor beacon: NotificareBeacon) {
        Logger.main.info("Started monitoring beacon = \(beacon.name)")
    }

    internal func notificare(_: NotificareGeo, monitoringDidFailFor region: NotificareRegion, with error: Error) {
        Logger.main.error("Failed to monitor region = \(region.name)\n\(error)")
    }

    internal func notificare(_: NotificareGeo, monitoringDidFailFor beacon: NotificareBeacon, with error: Error) {
        Logger.main.error("Failed to monitor beacon = \(beacon.name)\n\(error)")
    }

    internal func notificare(_: NotificareGeo, didDetermineState state: CLRegionState, for region: NotificareRegion) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        Logger.main.info("State for region '\(region.name)' = \(stateStr)")
    }

    internal func notificare(_: NotificareGeo, didDetermineState state: CLRegionState, for beacon: NotificareBeacon) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        Logger.main.info("State for beacon '\(beacon.name)' = \(stateStr)")
    }

    internal func notificare(_: NotificareGeo, didEnter region: NotificareRegion) {
        Logger.main.info("On region enter = \(region.name)")
    }

    internal func notificare(_: NotificareGeo, didEnter beacon: NotificareBeacon) {
        Logger.main.info("On beacon enter = \(beacon.name)")
    }

    internal func notificare(_: NotificareGeo, didExit region: NotificareRegion) {
        Logger.main.info("On region exit = \(region.name)")
    }

    internal func notificare(_: NotificareGeo, didExit beacon: NotificareBeacon) {
        Logger.main.info("On beacon exit = \(beacon.name)")
    }

    internal func notificare(_: NotificareGeo, didVisit visit: NotificareVisit) {
        Logger.main.info("On visit = \(String(describing: visit))")
    }

    internal func notificare(_: NotificareGeo, didUpdateHeading heading: NotificareHeading) {
        Logger.main.info("On heading updated = \(String(describing: heading))")
    }

    internal func notificare(_: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion) {
        if !beacons.isEmpty {
            Logger.main.info("On ranging beacons: \(beacons.map(\.name).joined(separator: " "))")
        }

        NotificationCenter.default.post(
            name: .beaconsRanged,
            object: nil,
            userInfo: [
                "region": region,
                "beacons": beacons,
            ]
        )
    }

    internal func notificare(_: NotificareGeo, didFailRangingFor region: NotificareRegion, with _: Error) {
        Logger.main.error("Failed to range beacons for region = \(region.name)")
    }
}

extension AppDelegate: NotificareMonetizeDelegate {
    internal func notificare(_: NotificareMonetize, didUpdateProducts products: [NotificareProduct]) {
        Logger.main.info("products updated = \(products)")
        Logger.main.info("products event == cached products : \(products.count == Notificare.shared.monetize().products.count)")
    }

    internal func notificare(_: NotificareMonetize, didUpdatePurchases purchases: [NotificarePurchase]) {
        Logger.main.info("purchases updated = \(purchases)")
    }

    internal func notificare(_: NotificareMonetize, didFinishPurchase purchase: NotificarePurchase) {
        Logger.main.info("purchase finished = \(String(describing: purchase))")
    }

    internal func notificare(_: NotificareMonetize, didRestorePurchase purchase: NotificarePurchase) {
        Logger.main.info("purchase restored = \(String(describing: purchase))")
    }

    internal func notificareDidCancelPurchase(_: NotificareMonetize) {
        Logger.main.info("purchase canceled")
    }

    internal func notificare(_: NotificareMonetize, didFailToPurchase error: Error) {
        Logger.main.error("purchase failed = \(error)")
    }

    internal func notificare(_: NotificareMonetize, processTransaction transaction: SKPaymentTransaction) {
        Logger.main.info("process transaction: identifier=\(transaction.transactionIdentifier ?? "") state=\(String(describing: transaction.transactionState))")
    }
}

extension AppDelegate: NotificareInAppMessagingDelegate {
    internal func notificare(_: NotificareInAppMessaging, didPresentMessage message: NotificareInAppMessage) {
        Logger.main.info("in-app message presented = \(String(describing: message))")
    }

    internal func notificare(_: NotificareInAppMessaging, didFinishPresentingMessage message: NotificareInAppMessage) {
        Logger.main.info("in-app message finished presenting = \(String(describing: message))")
    }

    internal func notificare(_: NotificareInAppMessaging, didFailToPresentMessage message: NotificareInAppMessage) {
        Logger.main.error("in-app message failed to present = \(String(describing: message))")
    }

    internal func notificare(_: NotificareInAppMessaging, didExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage) {
        Logger.main.info("in-app message action executed = \(String(describing: action))")
        Logger.main.info("for message = \(String(describing: message))")
    }

    internal func notificare(_: NotificareInAppMessaging, didFailToExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage, error _: Error?) {
        Logger.main.error("in-app message action failed to execute = \(String(describing: action))")
        Logger.main.error("for message = \(String(describing: message))")
    }
}

extension AppDelegate: NotificareScannablesDelegate {
    internal func notificare(_: NotificareScannables, didDetectScannable scannable: NotificareScannable) {
        guard let notification = scannable.notification else {
            Logger.main.info("Cannot present a scannable without a notification.")
            return
        }

        UIApplication.shared.present(notification)
    }

    internal func notificare(_: NotificareScannables, didInvalidateScannerSession error: Error) {
        Logger.main.error("Scannable session invalidated: \(error)")
    }
}
