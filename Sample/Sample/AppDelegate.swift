//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Atlantis
import CoreLocation
import NotificareAuthenticationKit
import NotificareGeoKit
import NotificareInboxKit
import NotificareKit
import NotificareLoyaltyKit
import NotificarePushKit
import NotificarePushUIKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Enable Proxyman debugging.
        Atlantis.start()

        if #available(iOS 14.0, *) {
            Notificare.shared.push().presentationOptions = [.banner, .badge, .sound]
        } else {
            Notificare.shared.push().presentationOptions = [.alert, .badge, .sound]
        }

        Notificare.shared.delegate = self
        Notificare.shared.push().delegate = self
        Notificare.shared.pushUI().delegate = self
        Notificare.shared.inbox().delegate = self
        Notificare.shared.geo().delegate = self

        Notificare.shared.launch()

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

        if let token = Notificare.shared.authentication().parsePasswordResetToken(url) {
            print("---> Password reset token = \(token)")
            return true
        }

        if let token = Notificare.shared.authentication().parseValidateUserToken(url) {
            print("---> Validate user token = \(token)")
            return true
        }

        return Notificare.shared.handleDynamicLinkUrl(url)
    }
}

extension AppDelegate: NotificareDelegate {
    func notificare(_: Notificare, onReady _: NotificareApplication) {
        print("-----> Notificare is ready.")

        if Notificare.shared.push().hasRemoteNotificationsEnabled {
            Notificare.shared.push().enableRemoteNotifications { _ in }
        }

        if Notificare.shared.geo().hasLocationServicesEnabled {
            Notificare.shared.geo().enableLocationUpdates()
        }
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

    func notificare(_: NotificarePush, didReceiveNotification notification: NotificareNotification) {
        print("-----> Notificare: received a notification: \(notification)")
    }

    func notificare(_: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        print("-----> Notificare: received an unknown notification: \(userInfo)")
    }

    func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {
        print("-----> Notificare: should open notification settings")
    }

    func notificare(_: NotificarePush, didReceiveUnknownAction action: [AnyHashable: Any], for _: [AnyHashable: Any]) {
        print("-----> Notificare: received an unknown action: \(action)")
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
        print("-----> On beacon enter = \(beacon.name)")
    }

    func notificare(_: NotificareGeo, didVisit visit: NotificareVisit) {
        print("-----> On visit = \(visit)")
    }

    func notificare(_: NotificareGeo, didUpdateHeading heading: NotificareHeading) {
        print("-----> On heading updated = \(heading)")
    }

    func notificare(_: NotificareGeo, didRange beacons: [NotificareBeacon], in region: NotificareRegion) {
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
