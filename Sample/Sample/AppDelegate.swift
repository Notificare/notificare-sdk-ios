//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import ActivityKit
// import Atlantis
import CoreLocation
import NotificareGeoKit
import NotificareInAppMessagingKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificareMonetizeKit
import NotificarePushKit
import NotificarePushUIKit
import StoreKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

        Notificare.shared.launch()

        if #available(iOS 16.1, *) {
            monitorLiveActivities()
            // startLiveActivity()
        }

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Notificare.shared.handleTestDeviceUrl(url) || Notificare.shared.handleDynamicLinkUrl(url) {
            return true
        }

        print("-----> Received deep link: \(url.absoluteString)")
        return true
    }

    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }

        if Notificare.shared.handleTestDeviceUrl(url) {
            return true
        }

        return Notificare.shared.handleDynamicLinkUrl(url)
    }

    @available(iOS 16.1, *)
    private func startLiveActivity() {
        Task.init {
            let attributes = SampleActivityAttributes(text: "Hello there")
            let contentState = SampleActivityAttributes.ContentState(value: 10)

            do {
                let activity = try Activity.request(attributes: attributes, contentState: contentState, pushType: .token)
                print("Live activity '\(activity.id)' started.")
            } catch {
                print("Failed to start a live activity: \(error)")
            }
        }
    }

    @available(iOS 16.1, *)
    private func monitorLiveActivities() {
        Task.init {
            // Listen to on-going and new Live Activities.
            for await activity in Activity<SampleActivityAttributes>.activityUpdates {
                Task.init {
                    // Listen to state changes of each activity.
                    for await state in activity.activityStateUpdates {
                        print("Live activity '\(activity.id)' state = '\(state)'")

                        switch activity.activityState {
                        case .active:
                            Task.init {
                                // Listen to push token updates of each active activity.
                                for await token in activity.pushTokenUpdates {
                                    do {
                                        try await Notificare.shared.push().registerLiveActivity("sample", token: token)
                                        print("Live activity '\(activity.id)' registered with token '\(token.toHexString())'.")
                                    } catch {
                                        print("Failed to register a live activity: \(error)")
                                    }
                                }
                            }

                        case .dismissed, .ended:
                            do {
                                try await Notificare.shared.push().endLiveActivity("sample")
                                print("Live activity '\(activity.id)' ended on Notificare.")
                            } catch {
                                print("Failed to end live activity '\(activity.id)' on Notificare: \(error)")
                            }

                        @unknown default:
                            print("Live activity '\(activity.id)' unknown state '\(state)'.")
                        }
                    }
                }
            }
        }
    }
}

extension AppDelegate: NotificareDelegate {
    func notificare(_: Notificare, onReady _: NotificareApplication) {
        print("-----> Notificare finished launching.")

        if Notificare.shared.push().hasRemoteNotificationsEnabled {
            Notificare.shared.push().enableRemoteNotifications { _ in }
        }

        if Notificare.shared.geo().hasLocationServicesEnabled {
            Notificare.shared.geo().enableLocationUpdates()
        }
    }

    func notificareDidUnlaunch(_: Notificare) {
        print("-----> Notificare finished un-launching.")
    }

    func notificare(_: Notificare, didRegisterDevice device: NotificareDevice) {
        print("-----> Notificare: device registered: \(device)")
    }
}

extension AppDelegate: NotificarePushDelegate {
    func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("-----> Notificare: failed to register for remote notifications: \(error)")
    }

    func notificare(_: NotificarePush, didChangeNotificationSettings granted: Bool) {
        print("-----> Notificare: notification settings changed: \(granted)")
    }

    func notificare(_: NotificarePush, didReceiveSystemNotification notification: NotificareSystemNotification) {
        print("-----> Notificare: received a system notification: \(notification)")
    }

    func notificare(_: NotificarePush, didReceiveNotification notification: NotificareNotification, deliveryMechanism: NotificareNotificationDeliveryMechanism) {
        print("-----> Notificare: received a notification: \(notification)")
        print("-----> Notificare: received notification delivery mechanism: \(deliveryMechanism)")
    }

    func notificare(_: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        print("-----> Notificare: received an unknown notification: \(userInfo)")
    }

    func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {
        print("-----> Notificare: should open notification settings")
    }

    func notificare(_: NotificarePush, didOpenNotification notification: NotificareNotification) {
        guard let rootViewController = window?.rootViewController else {
            return
        }

//        guard let scene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first ?? UIApplication.shared.connectedScenes.first,
//              let window = (scene.delegate as! UIWindowSceneDelegate).window!,
//              let rootViewController = window.rootViewController
//        else {
//            return
//        }

        Notificare.shared.pushUI().presentNotification(notification, in: rootViewController)
    }

    func notificare(_: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification) {
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

    func notificare(_: NotificarePush, didOpenUnknownNotification _: [AnyHashable: Any]) {
        print("-----> Notificare: opened unknown notification")
    }

    func notificare(_: NotificarePush, didOpenUnknownAction _: String, for _: [AnyHashable: Any], responseText _: String?) {
        print("-----> Notificare: opened unknown action")
    }
}

extension AppDelegate: NotificarePushUIDelegate {
    func notificare(_: NotificarePushUI, willPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: will present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFailToPresentNotification notification: NotificareNotification) {
        print("-----> Notificare: did fail to present notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFinishPresentingNotification notification: NotificareNotification) {
        print("-----> Notificare: did finish presenting notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didClickURL url: URL, in notification: NotificareNotification) {
        print("-----> Notificare: did click url '\(url)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, willExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: will execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didNotExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        print("-----> Notificare: did not execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didFailToExecuteAction action: NotificareNotification.Action, for notification: NotificareNotification, error _: Error?) {
        print("-----> Notificare: did fail to execute action '\(action.label)' in notification '\(notification.id)'")
    }

    func notificare(_: NotificarePushUI, didReceiveCustomAction _: URL, in _: NotificareNotification.Action, for _: NotificareNotification) {
        //
    }
}

extension AppDelegate: NotificareInboxDelegate {
    func notificare(_: NotificareInbox, didUpdateInbox items: [NotificareInboxItem]) {
        print("-----> Inbox has loaded. Total = \(items.count)")
    }

    func notificare(_: NotificareInbox, didUpdateBadge badge: Int) {
        print("-----> Badge update. Unread = \(badge)")
    }
}

extension AppDelegate: NotificareGeoDelegate {
    func notificare(_: NotificareGeo, didUpdateLocations locations: [NotificareLocation]) {
        print("-----> Locations updated = \(locations)")
    }

    func notificare(_: NotificareGeo, didFailWith error: Error) {
        print("-----> Location services failed = \(error)")
    }

    func notificare(_: NotificareGeo, didStartMonitoringFor region: NotificareRegion) {
        print("-----> Started monitoring region = \(region.name)")
    }

    func notificare(_: NotificareGeo, didStartMonitoringFor beacon: NotificareBeacon) {
        print("-----> Started monitoring beacon = \(beacon.name)")
    }

    func notificare(_: NotificareGeo, monitoringDidFailFor region: NotificareRegion, with error: Error) {
        print("-----> Failed to monitor region = \(region.name)\n\(error)")
    }

    func notificare(_: NotificareGeo, monitoringDidFailFor beacon: NotificareBeacon, with error: Error) {
        print("-----> Failed to monitor beacon = \(beacon.name)\n\(error)")
    }

    func notificare(_: NotificareGeo, didDetermineState state: CLRegionState, for region: NotificareRegion) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        print("-----> State for region '\(region.name)' = \(stateStr)")
    }

    func notificare(_: NotificareGeo, didDetermineState state: CLRegionState, for beacon: NotificareBeacon) {
        let stateStr: String
        switch state {
        case .inside:
            stateStr = "inside"
        case .outside:
            stateStr = "outside"
        case .unknown:
            stateStr = "unknown"
        }

        print("-----> State for beacon '\(beacon.name)' = \(stateStr)")
    }

    func notificare(_: NotificareGeo, didEnter region: NotificareRegion) {
        print("-----> On region enter = \(region.name)")
    }

    func notificare(_: NotificareGeo, didEnter beacon: NotificareBeacon) {
        print("-----> On beacon enter = \(beacon.name)")
    }

    func notificare(_: NotificareGeo, didExit region: NotificareRegion) {
        print("-----> On region exit = \(region.name)")
    }

    func notificare(_: NotificareGeo, didExit beacon: NotificareBeacon) {
        print("-----> On beacon exit = \(beacon.name)")
    }

    func notificare(_: NotificareGeo, didVisit visit: NotificareVisit) {
        print("-----> On visit = \(visit)")
    }

    func notificare(_: NotificareGeo, didUpdateHeading heading: NotificareHeading) {
        print("-----> On heading updated = \(heading)")
    }

    func notificare(_: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion) {
        if !beacons.isEmpty {
            print("-----> On ranging beacons: \(beacons.map(\.name).joined(separator: " "))")
        }

        NotificationCenter.default.post(
            name: .RangingBeacons,
            object: nil,
            userInfo: [
                "region": region,
                "beacons": beacons,
            ]
        )
    }

    func notificare(_: NotificareGeo, didFailRangingFor region: NotificareRegion, with _: Error) {
        print("-----> Failed to range beacons for region = \(region.name)")
    }
}

extension AppDelegate: NotificareMonetizeDelegate {
    func notificare(_: NotificareMonetize, didUpdateProducts products: [NotificareProduct]) {
        print("-----> products updated = \(products)")
        print("-----> products event == cached products : \(products.count == Notificare.shared.monetize().products.count)")
    }

    func notificare(_: NotificareMonetize, didUpdatePurchases purchases: [NotificarePurchase]) {
        print("-----> purchases updated = \(purchases)")
    }

    func notificare(_: NotificareMonetize, didFinishPurchase purchase: NotificarePurchase) {
        print("-----> purchase finished = \(purchase)")
    }

    func notificare(_: NotificareMonetize, didRestorePurchase purchase: NotificarePurchase) {
        print("-----> purchase restored = \(purchase)")
    }

    func notificareDidCancelPurchase(_: NotificareMonetize) {
        print("-----> purchase canceled")
    }

    func notificare(_: NotificareMonetize, didFailToPurchase error: Error) {
        print("-----> purchase failed = \(error)")
    }

    func notificare(_: NotificareMonetize, processTransaction transaction: SKPaymentTransaction) {
        print("-----> process transaction: identifier=\(transaction.transactionIdentifier ?? "") state=\(transaction.transactionState)")
    }
}

extension AppDelegate: NotificareInAppMessagingDelegate {
    func notificare(_: NotificareInAppMessaging, didPresentMessage message: NotificareInAppMessage) {
        print("-----> in-app message presented = \(message)")
    }

    func notificare(_: NotificareInAppMessaging, didFinishPresentingMessage message: NotificareInAppMessage) {
        print("-----> in-app message finished presenting = \(message)")
    }

    func notificare(_: NotificareInAppMessaging, didFailToPresentMessage message: NotificareInAppMessage) {
        print("-----> in-app message failed to present = \(message)")
    }

    func notificare(_: NotificareInAppMessaging, didExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage) {
        print("-----> in-app message action executed = \(action)")
        print("-----> for message = \(message)")
    }

    func notificare(_: NotificareInAppMessaging, didFailToExecuteAction action: NotificareInAppMessage.Action, for message: NotificareInAppMessage, error _: Error?) {
        print("-----> in-app message action failed to execute = \(action)")
        print("-----> for message = \(message)")
    }
}
