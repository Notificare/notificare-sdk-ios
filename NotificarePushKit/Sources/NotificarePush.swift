//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import UserNotifications

public class NotificarePush: NSObject, NotificareModule {
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

    public static func configure(applicationKey _: String, applicationSecret _: String) {
        guard !Notificare.shared.isConfigured else {
            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
            return
        }

        // TODO: check plist setting
        NotificarePush.shared.notificationCenter.delegate = NotificarePush.shared

        // Listen to 'application did become active'.
        NotificationCenter.default.addObserver(NotificarePush.shared,
                                               selector: #selector(updateNotificationSettings),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        if Notificare.shared.deviceManager.currentDevice?.transport == .notificare {
            NotificarePush.shared.updateNotificationSettings()
        }

        NotificarePush.shared.handleLaunchOptions()

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
                    Notificare.shared.logger.debug("Could not update user notification settings.")
                    completion?(.failure(error))
                }
            }
        } else {
            Notificare.shared.logger.debug("User notification settings update skipped, nothing changed.")
            completion?(.success(()))
        }
    }

    private func handleLaunchOptions() {
        // For safety reasons, handle the launch options on the main thread.
        DispatchQueue.main.async {
            // Check for the presence of a remote notification in the launch options.
            if let userInfo = Notificare.shared.launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
                if self.isNotificareNotification(userInfo) {
                    Notificare.shared.logger.info("Application launched via notification.")

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
                            Notificare.shared.eventsManager.logNotificationReceived(notification)
                            Notificare.shared.eventsManager.logNotificationInfluenced(notification)
                        case .failure:
                            break
                        }
                    }
                }
            }

//            // Handle URL Schemes at launch, this is needed when the application is force to awake and handle a click from an email message.
//            if let url = Notificare.shared.launchOptions?[.url] {
//                Notificare.shared.logger.info("Application launched from an URL.")
//            }
        }
    }
}
