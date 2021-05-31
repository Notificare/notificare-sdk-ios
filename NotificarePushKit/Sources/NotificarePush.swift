//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import MobileCoreServices
import NotificareKit
import UIKit
import UserNotifications

public class NotificarePush: NSObject, NotificareModule {
    public static let shared = NotificarePush()

    public weak var delegate: NotificarePushDelegate?
    public var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]
    public var categoryOptions: UNNotificationCategoryOptions
    public var presentationOptions: UNNotificationPresentationOptions = []
    public var isRemoteNotificationsEnabled: Bool {
        LocalStorage.remoteNotificationsEnabled
    }

    public private(set) var allowedUI: Bool {
        get { LocalStorage.allowedUI }
        set { LocalStorage.allowedUI = newValue }
    }

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

        if Notificare.shared.options!.userNotificationCenterDelegateEnabled {
            NotificareLogger.debug("Notificare will set itself as the UNUserNotificationCenter delegate.")
            NotificarePush.shared.notificationCenter.delegate = NotificarePush.shared
        } else {
            NotificareLogger.warning("""
            Please configure your plist settings to allow Notificare to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Notificare.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = NotificareSwizzler.addInterceptor(NotificarePush.shared)

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

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>) {
        // TODO: check if Notificare is ready and if the application services contain 'apns'.

        // Request notification authorization options.
        notificationCenter.requestAuthorization(options: authorizationOptions) { granted, _ in
            NotificareLogger.info("Registered user notification settings.")

            if granted {
                NotificareLogger.info("User granted permission to receive alerts, badge and sounds")
                self.reloadActionCategories()
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

        DispatchQueue.main.async {
            // Request an APNS token.
            UIApplication.shared.registerForRemoteNotifications()
        }

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = true
    }

    public func disableRemoteNotifications() {
        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = false

        Notificare.shared.deviceManager.registerTemporary { result in
            switch result {
            case .success:
                UIApplication.shared.unregisterForRemoteNotifications()
                NotificareLogger.info("Unregistered from APNS.")

            case let .failure(error):
                NotificareLogger.error("Failed to register a temporary device and unregister from APNS.")
                NotificareLogger.debug("\(error)")
            }
        }
    }

    public func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

    public func fetchAttachment(for userInfo: [AnyHashable: Any], _ completion: @escaping NotificareCallback<UNNotificationAttachment>) {
        guard let attachment = userInfo["attachment"] as? [String: Any],
              let uri = attachment["uri"] as? String
        else {
            NotificareLogger.warning("Could not find an attachment URI. Please ensure you're calling this method with the correct payload.")
            // TODO: create proper error
            completion(.failure(NotificareError.invalidArgument))
            return
        }

        guard let url = URL(string: uri) else {
            NotificareLogger.warning("Invalid attachment URI. Please ensure it's a valid URL.")
            completion(.failure(NotificareError.invalidArgument))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)[0]
            let fileName = url.pathComponents.last!
            let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName)

            guard let data = data, let response = response else {
                // TODO: create proper error
                completion(.failure(NotificareError.invalidArgument))
                return
            }

            do {
                try data.write(to: filePath, options: .atomic)
            } catch {
                // TODO: create proper error
                completion(.failure(NotificareError.invalidArgument))
                return
            }

            do {
                var options: [AnyHashable: Any] = [
                    UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0, y: 0, width: 1, height: 1),
                ]

                if let mimeType = response.mimeType,
                   let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
                {
                    options[UNNotificationAttachmentOptionsTypeHintKey] = uti.takeRetainedValue()
                }

                let attachment = try UNNotificationAttachment(identifier: "file_\(fileName)", url: filePath, options: options)
                completion(.success(attachment))
            } catch {
                // TODO: create proper error
                completion(.failure(NotificareError.invalidArgument))
                return
            }
        }.resume()
    }

    internal func reloadActionCategories() {
        NotificareLogger.debug("Reloading action categories.")

        let categories = loadAvailableCategories()
        notificationCenter.setNotificationCategories(categories)
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
            let actions = category.actions.map { action -> UNNotificationAction in
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
        guard Notificare.shared.isReady else {
            return
        }

        notificationCenter.getNotificationSettings { settings in
            var allowedUI = settings.authorizationStatus == .authorized

            if #available(iOS 12.0, *) {
                if settings.authorizationStatus == .provisional {
                    allowedUI = true
                }
            }

            self.handleNotificationSettings(allowedUI) { _ in }
        }
    }

    private func handleNotificationSettings(_ allowedUI: Bool, _ completion: @escaping NotificareCallback<Void>) {
        guard let device = Notificare.shared.deviceManager.currentDevice else {
            completion(.failure(NotificareError.notReady))
            return
        }

        if self.allowedUI != allowedUI {
            let payload = PushAPI.Payloads.UpdateNotificationSettings(
                allowedUI: allowedUI
            )

            NotificareRequest.Builder()
                .put("/device/\(device.id)", body: payload)
                .response { result in
                    switch result {
                    case .success:
                        NotificareLogger.debug("User notification settings updated.")

                        // Update current stored property.
                        self.allowedUI = allowedUI

                        // Notify the delegate.
                        self.delegate?.notificare(self, didChangeNotificationSettings: allowedUI)

                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
        } else {
            NotificareLogger.debug("User notification settings update skipped, nothing changed.")
            completion(.success(()))
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

// Protocol conformance exposed as UIApplicationDelegate.
extension NotificarePush: NotificareAppDelegateInterceptor {}
