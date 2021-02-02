//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareCore
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
            NotificareLogger.warning("Notificare has already been configured. Skipping...")
            return
        }

        if let configuration = NotificareUtils.getConfiguration(), configuration.userNotificationCenterDelegateEnabled {
            NotificareLogger.debug("Notificare will set itself as the UNUserNotificationCenter delegate.")
            NotificarePush.shared.notificationCenter.delegate = NotificarePush.shared
        } else {
            NotificareLogger.warning("""
            Please configure your plist settings to allow Notificare to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Notificare.
            """)
        }

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
            NotificareLogger.info("Registered user notification settings.")

            if granted {
                NotificareLogger.info("User granted permission to receive alerts, badge and sounds")

                let categories = self.loadAvailableCategories()
                self.notificationCenter.setNotificationCategories(categories)
            } else {
                NotificareLogger.info("User did not grant permission to receive alerts, badge and sounds.")
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
                    hiddenPreviewsBodyPlaceholder: NotificareLocalizable.string(resource: .pushDefaultCategory),
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
                        title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                        options: .destructive
                    )
                } else if action.type == "re.notifica.action.Callback" {
                    // Check if needs camera or keyboard, if it does we will need to open the app.
                    if action.camera {
                        // Yeah let's set it to open the app.
                        return UNNotificationAction(
                            identifier: action.label,
                            title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                            options: [.foreground, .authenticationRequired]
                        )
                    } else if action.keyboard {
                        return UNTextInputNotificationAction(
                            identifier: action.label,
                            title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                            options: [],
                            textInputButtonTitle: NotificareLocalizable.string(resource: .actionsSend),
                            textInputPlaceholder: NotificareLocalizable.string(resource: .actionsInputPlaceholder)
                        )
                    } else {
                        // No need to open the app. Let's set it to be executed in the background and with no authentication required.
                        // This is mostly a Response or a Webhook request.
                        return UNNotificationAction(
                            identifier: action.label,
                            title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                            options: []
                        )
                    }
                } else {
                    return UNNotificationAction(
                        identifier: action.label,
                        title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
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
                        hiddenPreviewsBodyPlaceholder: NotificareLocalizable.string(resource: category.name, fallback: category.name),
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
                    NotificareLogger.debug("User notification settings updated.")
                    completion?(.success(()))
                case let .failure(error):
                    NotificareLogger.debug("Could not update user notification settings.")
                    completion?(.failure(error))
                }
            }
        } else {
            NotificareLogger.debug("User notification settings update skipped, nothing changed.")
            completion?(.success(()))
        }
    }

    private func handleLaunchOptions() {
        // For safety reasons, handle the launch options on the main thread.
        DispatchQueue.main.async {
            // Check for the presence of a remote notification in the launch options.
            if let userInfo = Notificare.shared.launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
                if self.isNotificareNotification(userInfo) {
                    NotificareLogger.info("Application launched via notification.")

                    guard let id = userInfo["id"] as? String else {
                        NotificareLogger.warning("Missing 'id' property in notification payload.")
                        return
                    }

                    guard Notificare.shared.isConfigured else {
                        NotificareLogger.warning("Notificare has not been configured.")
                        return
                    }

                    Notificare.shared.fetchNotification(id) { result in
                        switch result {
                        case let .success(notification):
                            Notificare.shared.eventsManager.logNotificationInfluenced(notification)
                        case .failure:
                            break
                        }
                    }
                }
            }

//            // Handle URL Schemes at launch, this is needed when the application is force to awake and handle a click from an email message.
//            if let url = Notificare.shared.launchOptions?[.url] {
//                NotificareLogger.info("Application launched from an URL.")
//            }
        }
    }
}
