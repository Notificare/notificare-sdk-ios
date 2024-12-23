//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import ActivityKit
import CoreLocation
import Foundation
import NotificareKit
import NotificarePushKit
import NotificarePushUIKit
import OSLog
import StoreKit
import SwiftUI
import UIKit

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal var window: UIWindow?

    internal func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if #available(iOS 14.0, *) {
            Notificare.shared.push().presentationOptions = [.banner, .badge, .sound]
        } else {
            Notificare.shared.push().presentationOptions = [.alert, .badge, .sound]
        }

        Notificare.shared.delegate = self
        Notificare.shared.push().delegate = self
        Notificare.shared.pushUI().delegate = self

        Task {
            do {
                try await Notificare.shared.launch()
            } catch {
                Logger.main.error("Failed to launch Notificare. \(error)")
            }
        }

        if Notificare.shared.canEvaluateDeferredLink {
            Notificare.shared.evaluateDeferredLink { result in
                switch result {
                case let .success(evaluated):
                    Logger.main.info("deferred link evaluation = \(evaluated)")
                case let .failure(error):
                    Logger.main.error("Failed to evaluate the deferred link. \(error)")
                }
            }
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
}

extension AppDelegate: NotificarePushDelegate {
    internal func notificare(_: NotificarePush, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.main.error("Notificare: failed to register for remote notifications: \(error)")
    }

    internal func notificare(_ notificarePush: any NotificarePush, didChangeSubscription subscription: NotificarePushSubscription?) {
        Logger.main.info("Notificare: subscription changed: \(String(describing: subscription))")
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

        NotificationCenter.default.post(
            name: .notifyInboxUpdate,
            object: nil
        )
    }

    internal func notificare(_: NotificarePush, didReceiveUnknownNotification userInfo: [AnyHashable: Any]) {
        Logger.main.info("Notificare: received an unknown notification: \(userInfo)")
    }

    internal func notificare(_: NotificarePush, shouldOpenSettings _: NotificareNotification?) {
        Logger.main.info("Notificare: should open notification settings")
    }

    internal func notificare(_: NotificarePush, didOpenNotification notification: NotificareNotification) {
        UIApplication.shared.present(notification)

        NotificationCenter.default.post(
            name: .notifyInboxUpdate,
            object: nil
        )
    }

    internal func notificare(_: NotificarePush, didOpenAction action: NotificareNotification.Action, for notification: NotificareNotification) {
        guard let rootViewController = window?.rootViewController else {
            return
        }

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
