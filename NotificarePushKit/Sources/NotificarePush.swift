//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import UserNotifications

public class NotificarePush: NSObject, NotificareModule {
    public typealias LaunchResult = Void

    public static let shared = NotificarePush()

    public weak var delegate: NotificarePushDelegate?
    public var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]
    public var categoryOptions: UNNotificationCategoryOptions
    public var presentationOptions: UNNotificationPresentationOptions = []

    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    override init() {
        if #available(iOS 11.0, *) {
            categoryOptions = [.customDismissAction, .hiddenPreviewsShowTitle]
        } else {
            categoryOptions = [.customDismissAction]
        }
    }

    public func configure(applicationKey _: String, applicationSecret _: String) {
//        guard !Notificare.shared.isConfigured else {
//            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
//            return
//        }

        // TODO: check plist setting
        notificationCenter.delegate = self

        // Listen to 'application did become active'.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNotificationSettings),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        if Notificare.shared.deviceManager.currentDevice?.transport == .notificare {
            updateNotificationSettings()
        }

        completion(.success(()))
    }

    public func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>) {
        // Request notification authorization options.
        notificationCenter.requestAuthorization(options: authorizationOptions) { granted, _ in
            Notificare.shared.logger.info("Registered user notification settings.")

            if granted {
                Notificare.shared.logger.info("User granted permission to receive alerts, badge and sounds")

                let categories = self.loadAvailableCategories()
                self.notificationCenter.setNotificationCategories(categories)
            } else {
                Notificare.shared.logger.info("User did not grant permission to receive alerts, badge and sounds.")
            }

            self.handleNotificationSettings(granted) { result in
                switch result {
                case .success:
                    completion(.success(granted))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        // Request an APNS token.
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func disableRemoteNotifications() {}

    public func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

    private func loadAvailableCategories() -> Set<UNNotificationCategory> {
        var categories = Set<UNNotificationCategory>()

        if #available(iOS 11.0, *) {
            categories.insert(
                UNNotificationCategory(
                    identifier: "NotificareDefaultCategory",
                    actions: [],
                    intentIdentifiers: [],
                    hiddenPreviewsBodyPlaceholder: NSLocalizedString("NotificareDefaultCategory", comment: "notification"),
                    options: categoryOptions
                )
            )
        } else {
            categories.insert(
                UNNotificationCategory(
                    identifier: "NotificareDefaultCategory",
                    actions: [],
                    intentIdentifiers: [],
                    options: categoryOptions
                )
            )
        }

        // Loop over all the application info actionCategories list of Rich Push templates created for this application.
        Notificare.shared.application?.actionCategories.forEach { category in
            let actions = category.actions.map { (action) -> UNNotificationAction in
                if action.destructive {
                    return UNNotificationAction(
                        identifier: action.label,
                        title: stringFromBundle(action.label) ?? action.label,
                        options: .destructive
                    )
                } else if action.type == "re.notifica.action.Callback" {
                    // Check if needs camera or keyboard, if it does we will need to open the app.
                    if action.camera {
                        // Yeah let's set it to open the app.
                        return UNNotificationAction(
                            identifier: action.label,
                            title: stringFromBundle(action.label) ?? action.label,
                            options: [.foreground, .authenticationRequired]
                        )
                    } else if action.keyboard {
                        return UNTextInputNotificationAction(
                            identifier: action.label,
                            title: stringFromBundle(action.label) ?? action.label,
                            options: [],
                            textInputButtonTitle: stringFromBundle("send") ?? "send",
                            textInputPlaceholder: stringFromBundle("type_some_text") ?? "type_some_text"
                        )
                    } else {
                        // No need to open the app. Let's set it to be executed in the background and with no authentication required.
                        // This is mostly a Response or a Webhook request.
                        return UNNotificationAction(
                            identifier: action.label,
                            title: stringFromBundle(action.label) ?? action.label,
                            options: []
                        )
                    }
                } else {
                    return UNNotificationAction(
                        identifier: action.label,
                        title: stringFromBundle(action.label) ?? action.label,
                        options: [.foreground, .authenticationRequired]
                    )
                }
            }

            if #available(iOS 11.0, *) {
                categories.insert(
                    UNNotificationCategory(
                        identifier: category.name,
                        actions: actions,
                        intentIdentifiers: [],
                        hiddenPreviewsBodyPlaceholder: NSLocalizedString(category.name, comment: ""),
                        options: categoryOptions
                    )
                )
            } else {
                categories.insert(
                    UNNotificationCategory(
                        identifier: category.name,
                        actions: actions,
                        intentIdentifiers: [],
                        options: categoryOptions
                    )
                )
            }
        }

        return categories
    }

    private func stringFromBundle(_: String) -> String? {
        // TODO:
        nil
    }

    @objc private func updateNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            var allowedUI = settings.authorizationStatus == .authorized

            if #available(iOS 12.0, *) {
                if settings.authorizationStatus == .provisional {
                    allowedUI = true
                }
            }

            self.handleNotificationSettings(allowedUI)
        }
    }

    private func handleNotificationSettings(_ allowedUI: Bool, _ completion: NotificareCallback<Void>? = nil) {
        // Notify the delegate.
        delegate?.notificare(self, didChangeNotificationSettings: allowedUI)

        if Notificare.shared.deviceManager.currentDevice?.allowedUI != allowedUI {
            Notificare.shared.deviceManager.updateNotificationSettings(allowedUI) { result in
                switch result {
                case .success:
                    Notificare.shared.logger.debug("User notification settings updated.")
                    completion?(.success(()))
                case let .failure(error):
                    Notificare.shared.logger.debug("Could not user notification settings.")
                    completion?(.failure(error))
                }
            }
        } else {
            Notificare.shared.logger.debug("User notification settings update skipped, nothing changed.")
            completion?(.success(()))
        }
    }

    func handleSystemNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        if let type = userInfo["systemType"] as? String, type.hasPrefix("re.notifica.") {
            Notificare.shared.logger.info("Processing system notification: \(type)")

            switch type {
            case "re.notifica.notification.system.Application":
                break
            case "re.notifica.notification.system.Wallet":
                break
            case "re.notifica.notification.system.Products":
                break
            case "re.notifica.notification.system.Inbox":
                break
            default:
                Notificare.shared.logger.warning("Unhandled system notification: \(type)")
            }
        } else {
            Notificare.shared.logger.info("Processing custom system notification.")

            let notification = NotificareSystemNotification(userInfo: userInfo)
            delegate?.notificare(self, didReceiveSystemNotification: notification)

            completion(.success(()))
        }
    }

    func handleNotification(_ userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        guard let id = userInfo["id"] as? String else {
            Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard let api = Notificare.shared.pushApi else {
            Notificare.shared.logger.warning("Notificare has not been configured.")
            return
        }

        api.getNotification(id) { result in
            switch result {
            case let .success(notification):
                // TODO: log notification received

                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func handleAction(_ action: String, for notification: [AnyHashable: Any], with data: [AnyHashable: Any], _ completion: @escaping NotificareCallback<Void>) {
        _ = action
        _ = notification
        _ = data
        _ = completion
    }
}

extension NotificarePush: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                var data = ["identifier": response.actionIdentifier]

                if let response = response as? UNTextInputNotificationResponse {
                    data["userText"] = response.userText
                }

                handleAction(response.actionIdentifier, for: userInfo, with: data) { result in
                    switch result {
                    case .success:
                        // TODO: refresh badge
                        // [[NotificareInboxManager shared] refreshBadge:^(id  _Nullable response, NSError * _Nullable error) {
                        //     completionHandler();
                        // }];
                        completionHandler()
                    case .failure:
                        completionHandler()
                    }
                }
            } else {
                guard let id = userInfo["id"] as? String else {
                    Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
                    return
                }

                guard let api = Notificare.shared.pushApi else {
                    Notificare.shared.logger.warning("Notificare has not been configured.")
                    return
                }

                api.getNotification(id) { result in
                    switch result {
                    case let .success(notification):
                        self.delegate?.notificare(self, didReceiveNotification: notification)
                    case .failure:
                        Notificare.shared.logger.error("Failed to fetch notification with id '\(id)'.")
                    }
                }

                completionHandler()
            }
        } else {
            // Unrecognizable notification
            if response.actionIdentifier != UNNotificationDefaultActionIdentifier, response.actionIdentifier != UNNotificationDismissActionIdentifier {
                var data = ["identifier": response.actionIdentifier]

                if let response = response as? UNTextInputNotificationResponse {
                    data["userText"] = response.userText
                }

                delegate?.notificare(self, didReceiveUnknownAction: data, for: userInfo)
            } else {
                delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            }

            completionHandler()
        }
    }

    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if isNotificareNotification(userInfo) {
            guard let id = userInfo["id"] as? String else {
                Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
                return
            }

            guard let api = Notificare.shared.pushApi else {
                Notificare.shared.logger.warning("Notificare has not been configured.")
                return
            }

            api.getNotification(id) { result in
                switch result {
                case let .success(notification):
                    self.delegate?.notificare(self, didReceiveNotification: notification)

                    // Check if we should force-set the presentation options.
                    if let presentation = userInfo["presentation"] as? Bool, presentation {
                        completionHandler([.alert, .badge, .sound])
                    } else {
                        completionHandler(self.presentationOptions)
                    }
                case .failure:
                    Notificare.shared.logger.error("Failed to fetch notification with id '\(id)'.")
                    completionHandler([])
                }
            }
        } else {
            // Unrecognizable notification
            delegate?.notificare(self, didReceiveUnknownNotification: userInfo)
            completionHandler([])
        }
    }

    public func userNotificationCenter(_: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        guard let notification = notification else {
            delegate?.notificare(self, shouldOpenSettings: nil)
            return
        }

        let userInfo = notification.request.content.userInfo

        guard isNotificareNotification(userInfo) else {
            Notificare.shared.logger.debug("Cannot handle a notification from a provider other than Notificare.")
            return
        }

        guard let id = userInfo["id"] as? String else {
            Notificare.shared.logger.warning("Missing 'id' property in notification payload.")
            return
        }

        guard let api = Notificare.shared.pushApi else {
            Notificare.shared.logger.warning("Notificare has not been configured.")
            return
        }

        api.getNotification(id) { result in
            switch result {
            case let .success(notification):
                self.delegate?.notificare(self, shouldOpenSettings: notification)
            case .failure:
                Notificare.shared.logger.error("Failed to fetch notification with id '\(id)' for notification settings.")
            }
        }
    }
}
