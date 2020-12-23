//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import NotificareKit
import UIKit
import UserNotifications

public class NotificarePush: NSObject, NotificareModule {
    public typealias LaunchResult = Void

    public static let shared = NotificarePush()

    weak var delegate: NotificarePushDelegate?
    var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]
    var categoryOptions: UNNotificationCategoryOptions

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
        guard !Notificare.shared.isConfigured else {
            Notificare.shared.logger.warning("Notificare has already been configured. Skipping...")
            return
        }

        // TODO: check plist setting
        notificationCenter.delegate = self

        // Listen to 'application did become active'.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNotificationSettings),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public func enableRemoteNotifications() {
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

            self.handleNotificationSettings(granted)
        }

        // Request an APNS token.
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func disableRemoteNotifications() {}

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

    private func handleNotificationSettings(_ allowedUI: Bool) {
        // Notify the delegate.
        delegate?.notificare(self, didChangeNotificationSettings: allowedUI)

        if Notificare.shared.deviceManager.currentDevice?.allowedUI != allowedUI {
            Notificare.shared.deviceManager.updateNotificationSettings(allowedUI) { result in
                switch result {
                case .success:
                    Notificare.shared.logger.debug("User notification settings updated.")
                case .failure:
                    Notificare.shared.logger.debug("Could not user notification settings.")
                }
            }
        } else {
            Notificare.shared.logger.debug("User notification settings update skipped, nothing changed.")
        }
    }
}

extension NotificarePush: UNUserNotificationCenterDelegate {}

extension NotificareDeviceManager {
    func updateNotificationSettings(_: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
