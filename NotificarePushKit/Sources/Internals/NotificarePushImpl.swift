//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import MobileCoreServices
import NotificareKit
import UIKit
import UserNotifications

internal class NotificarePushImpl: NSObject, NotificareModule, NotificarePush {
    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    // MARK: - Notificare Module

    static let instance = NotificarePushImpl()

    func migrate() {
        let allowedUI = UserDefaults.standard.bool(forKey: "notificareAllowedUI")

        LocalStorage.allowedUI = allowedUI
        LocalStorage.remoteNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificareRegisteredForNotifications")

        if allowedUI {
            // Prevent the lib from sending the push registration event for existing devices.
            LocalStorage.firstRegistration = false
        }
    }

    func configure() {
        if Notificare.shared.options!.userNotificationCenterDelegateEnabled {
            NotificareLogger.debug("Notificare will set itself as the UNUserNotificationCenter delegate.")
            notificationCenter.delegate = self
        } else {
            NotificareLogger.warning("""
            Please configure your plist settings to allow Notificare to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Notificare.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = NotificareSwizzler.addInterceptor(self)

        // Listen to 'application did become active'.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationForeground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func launch(_ completion: @escaping NotificareCallback<Void>) {
        // Ensure the definitive allowedUI value has been communicated to the API.
        updateNotificationSettings(completion)
    }

    // TODO: confirm we do not need unlaunch

    // MARK: Notificare Push Module

    public weak var delegate: NotificarePushDelegate?

    public var authorizationOptions: UNAuthorizationOptions = [.badge, .sound, .alert]

    public var categoryOptions: UNNotificationCategoryOptions = {
        if #available(iOS 11.0, *) {
            return [.customDismissAction, .hiddenPreviewsShowTitle]
        } else {
            return [.customDismissAction]
        }
    }()

    public var presentationOptions: UNNotificationPresentationOptions = []

    public var hasRemoteNotificationsEnabled: Bool {
        LocalStorage.remoteNotificationsEnabled
    }

    public private(set) var allowedUI: Bool {
        get { LocalStorage.allowedUI }
        set { LocalStorage.allowedUI = newValue }
    }

    public func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>) {
        // TODO: check if Notificare is ready and if the application services contain 'apns'.

        // Request notification authorization options.
        notificationCenter.requestAuthorization(options: authorizationOptions) { granted, _ in
            NotificareLogger.info("Registered user notification settings.")

            if granted {
                NotificareLogger.info("User granted permission to receive alerts, badge and sounds.")
                self.reloadActionCategories {
                    self.handleEnabledRemoteNotifications(granted, completion)
                }
            } else {
                NotificareLogger.info("User did not grant permission to receive alerts, badge and sounds.")
                self.handleEnabledRemoteNotifications(granted, completion)
            }
        }

        DispatchQueue.main.async {
            // Request an APNS token.
            UIApplication.shared.registerForRemoteNotifications()
        }

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = true
    }

    @available(iOS 13.0, *)
    public func enableRemoteNotifications() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            enableRemoteNotifications { result in
                continuation.resume(with: result)
            }
        }
    }

    public func disableRemoteNotifications() {
        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = false

        Notificare.shared.deviceInternal().registerTemporary { result in
            switch result {
            case .success:
                // Unregister from APNS
                UIApplication.shared.unregisterForRemoteNotifications()

                // Update the local notification settings.
                // Registering a temporary device automatically reports the allowedUI to the API.
                LocalStorage.allowedUI = false

                NotificareLogger.info("Unregistered from APNS.")
            case let .failure(error):
                NotificareLogger.error("Failed to register a temporary device and unregister from APNS.", error: error)
            }
        }
    }

    public func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

    public func handleNotificationRequest(_ request: UNNotificationRequest, _ completion: @escaping NotificareCallback<UNNotificationContent>) {
        let content = request.content.mutableCopy() as! UNMutableNotificationContent

        if #available(iOS 15.0, *) {
            if let interruptionLevel = request.content.userInfo["interruptionLevel"] as? String {
                switch interruptionLevel {
                case "active":
                    content.interruptionLevel = .active
                case "passive":
                    content.interruptionLevel = .passive
                case "timeSensitive":
                    content.interruptionLevel = .timeSensitive
                case "critical":
                    content.interruptionLevel = .critical
                default:
                    NotificareLogger.warning("Unexpected interruption level '\(interruptionLevel)' in notification payload.")
                }
            }

            if let relevanceScore = request.content.userInfo["relevanceScore"] as? Double, 0 ... 1 ~= relevanceScore {
                content.relevanceScore = relevanceScore
            }
        }

        fetchAttachment(for: request) { result in
            switch result {
            case let .success(attachment):
                content.attachments = [attachment]
                completion(.success(content))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String], _ completion: @escaping NotificareCallback<Void>) {
        Task.init {
            do {
                try await registerLiveActivity(activityId, token: token, topics: topics)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @available(iOS 16.1, *)
    func registerLiveActivity(_ activityId: String, token: String, topics: [String]) async throws {
        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let payload = NotificareInternals.PushAPI.Payloads.RegisterLiveActivity(
            activity: activityId,
            token: token,
            deviceID: device.id,
            topics: topics
        )

        _ = try await NotificareRequest.Builder()
            .post("/live-activity", body: payload)
            .response()
    }

    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String, _ completion: @escaping NotificareCallback<Void>) {
        Task.init {
            do {
                try await endLiveActivity(activityId)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @available(iOS 16.1, *)
    func endLiveActivity(_ activityId: String) async throws {
        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let encodedActivityId = activityId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let encodedDeviceId = device.id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

        _ = try await NotificareRequest.Builder()
            .delete("/live-activity/\(encodedActivityId)/\(encodedDeviceId)")
            .response()
    }

    // MARK: Internal API

    internal func reloadActionCategories(_ completion: @escaping () -> Void) {
        NotificareLogger.debug("Reloading action categories.")

        if Notificare.shared.options?.preserveExistingNotificationCategories == true {
            notificationCenter.getNotificationCategories { existingCategories in
                let categories = existingCategories.union(self.loadAvailableCategories())
                self.notificationCenter.setNotificationCategories(categories)

                completion()
            }
        } else {
            let categories = loadAvailableCategories()
            notificationCenter.setNotificationCategories(categories)

            completion()
        }
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
                if action.destructive == true {
                    return buildNotificationAction(action, options: .destructive)
                } else if action.type == "re.notifica.action.Callback" {
                    // Check if needs camera or keyboard, if it does we will need to open the app.
                    if action.camera {
                        // Yeah let's set it to open the app.
                        return buildNotificationAction(action, options: [.foreground, .authenticationRequired])
                    } else if action.keyboard {
                        return buildTextInputNotificationAction(action, options: [])
                    } else {
                        // No need to open the app. Let's set it to be executed in the background and with no authentication required.
                        // This is mostly a Response or a Webhook request.
                        return buildNotificationAction(action, options: [])
                    }
                } else {
                    return buildNotificationAction(action, options: [.foreground, .authenticationRequired])
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

    private func buildNotificationAction(_ action: NotificareNotification.Action, options: UNNotificationActionOptions) -> UNNotificationAction {
        if #available(iOS 15.0, *), let icon = action.icon?.ios {
            return UNNotificationAction(
                identifier: action.label,
                title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                options: options,
                icon: UNNotificationActionIcon(systemImageName: icon)
            )
        }

        return UNNotificationAction(
            identifier: action.label,
            title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
            options: options
        )
    }

    private func buildTextInputNotificationAction(_ action: NotificareNotification.Action, options: UNNotificationActionOptions) -> UNTextInputNotificationAction {
        if #available(iOS 15.0, *), let icon = action.icon?.ios {
            return UNTextInputNotificationAction(
                identifier: action.label,
                title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
                options: options,
                icon: UNNotificationActionIcon(systemImageName: icon),
                textInputButtonTitle: NotificareLocalizable.string(resource: .sendButton),
                textInputPlaceholder: NotificareLocalizable.string(resource: .actionsInputPlaceholder)
            )
        }

        return UNTextInputNotificationAction(
            identifier: action.label,
            title: NotificareLocalizable.string(resource: action.label, fallback: action.label),
            options: options,
            textInputButtonTitle: NotificareLocalizable.string(resource: .sendButton),
            textInputPlaceholder: NotificareLocalizable.string(resource: .actionsInputPlaceholder)
        )
    }

    @objc private func onApplicationForeground() {
        guard Notificare.shared.isReady else {
            return
        }

        updateNotificationSettings { _ in }
    }

    internal func updateNotificationSettings(_ completion: @escaping NotificareCallback<Void>) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                var allowedUI = settings.authorizationStatus == .authorized

                if #available(iOS 12.0, *) {
                    if settings.authorizationStatus == .provisional {
                        allowedUI = true
                    }
                }

                self.handleNotificationSettings(allowedUI, completion)
            }
        }
    }

    private func handleNotificationSettings(_ granted: Bool, _ completion: @escaping NotificareCallback<Void>) {
        guard Notificare.shared.isConfigured else {
            completion(.failure(NotificareError.notConfigured))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        // The allowedUI is only true when the device has push capabilities and the user accepted the permission.
        let allowedUI = device.transport != .notificare && granted

        if self.allowedUI != allowedUI {
            let payload = NotificareInternals.PushAPI.Payloads.UpdateNotificationSettings(
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

                        DispatchQueue.main.async {
                            // Notify the delegate.
                            self.delegate?.notificare(self, didChangeNotificationSettings: allowedUI)
                        }

                        completion(.success(()))
                    case let .failure(error):
                        NotificareLogger.error("Failed to update the remote notification settings.", error: error)
                        completion(.failure(error))
                    }
                }
        } else {
            NotificareLogger.debug("User notification settings update skipped, nothing changed.")
            completion(.success(()))
        }
    }

    private func handleEnabledRemoteNotifications(_ granted: Bool, _ completion: @escaping NotificareCallback<Bool>) {
        handleNotificationSettings(granted) { result in
            switch result {
            case .success:
                if granted, LocalStorage.firstRegistration {
                    Notificare.shared.events().logPushRegistration { result in
                        switch result {
                        case .success:
                            LocalStorage.firstRegistration = false
                            completion(.success(granted))
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }

                    return
                }

                completion(.success(granted))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func fetchAttachment(for request: UNNotificationRequest, _ completion: @escaping NotificareCallback<UNNotificationAttachment>) {
        guard let attachment = request.content.userInfo["attachment"] as? [String: Any],
              let uri = attachment["uri"] as? String
        else {
            NotificareLogger.warning("Could not find an attachment URI. Please ensure you're calling this method with the correct payload.")
            completion(.failure(NotificareError.invalidArgument(message: "Notification request has no attachment URI.")))
            return
        }

        guard let url = URL(string: uri) else {
            NotificareLogger.warning("Invalid attachment URI. Please ensure it's a valid URL.")
            completion(.failure(NotificareError.invalidArgument(message: "Invalid attachment URI.")))
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
                completion(.failure(NotificareError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
                return
            }

            do {
                try data.write(to: filePath, options: .atomic)
            } catch {
                completion(.failure(NotificareError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
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
                completion(.failure(NotificareError.invalidArgument(message: "Failed to download attachment from the provided URI.")))
                return
            }
        }.resume()
    }
}
