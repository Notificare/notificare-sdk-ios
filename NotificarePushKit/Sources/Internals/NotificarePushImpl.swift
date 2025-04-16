//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Combine
import Foundation
import MobileCoreServices
import NotificareKit
import UIKit
import UserNotifications

internal class NotificarePushImpl: NSObject, NotificareModule, NotificarePush {
    private var notificationCenter: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    private var _subscriptionStream: CurrentValueSubject<NotificarePushSubscription?, Never> = .init(LocalStorage.subscription)
    private var _allowedUIStream: CurrentValueSubject<Bool, Never> = .init(LocalStorage.allowedUI)

    internal let applicationDelegateInterceptor = NotificarePushAppDelegateInterceptor()
    internal let notificationCenterDelegate = NotificareNotificationCenterDelegate()
    internal let pushTokenRequester = PushTokenRequester()

    // MARK: - Notificare Module

    internal static let instance = NotificarePushImpl()

    internal func migrate() {
        let allowedUI = UserDefaults.standard.bool(forKey: "notificareAllowedUI")

        LocalStorage.allowedUI = allowedUI
        LocalStorage.remoteNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificareRegisteredForNotifications")

        if allowedUI {
            // Prevent the lib from sending the push registration event for existing devices.
            LocalStorage.firstRegistration = false
        }
    }

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false

        if Notificare.shared.options!.userNotificationCenterDelegateEnabled {
            logger.debug("Notificare will set itself as the UNUserNotificationCenter delegate.")
            notificationCenter.delegate = notificationCenterDelegate
        } else {
            logger.warning("""
            Please configure your plist settings to allow Notificare to become the UNUserNotificationCenter delegate. \
            Alternatively forward the UNUserNotificationCenter delegate events to Notificare.
            """)
        }

        // Register interceptor to receive APNS swizzled events.
        _ = NotificareSwizzler.addInterceptor(applicationDelegateInterceptor)

        // Listen to 'application did become active'.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        LocalStorage.clear()

        _subscriptionStream.value = LocalStorage.subscription
        _allowedUIStream.value = LocalStorage.allowedUI
    }

    internal func postLaunch() async throws {
        if hasRemoteNotificationsEnabled {
            logger.debug("Enabling remote notifications automatically.")
            try await updateDeviceSubscription()

            if await hasNotificationPermission() {
                await reloadActionCategories()
            }
        }
    }

    internal func unlaunch() async throws {
        // Unregister from APNS
        await UIApplication.shared.unregisterForRemoteNotifications()
        logger.info("Unregistered from APNS.")

        // Reset local storage
        LocalStorage.remoteNotificationsEnabled = false
        LocalStorage.firstRegistration = true

        self.transport = nil
        self.subscription = nil
        self.allowedUI = false

        notifySubscriptionUpdated(nil)
        notifyAllowedUIUpdated(false)
    }

    // MARK: Notificare Push Module

    public weak var delegate: NotificarePushDelegate?

    public var subscriptionStream: AnyPublisher<NotificarePushSubscription?, Never> { _subscriptionStream.eraseToAnyPublisher() }
    public var allowedUIStream: AnyPublisher<Bool, Never> { _allowedUIStream.eraseToAnyPublisher() }

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

    public private(set) var transport: NotificareTransport? {
        get { LocalStorage.transport }
        set { LocalStorage.transport = newValue }
    }

    public private(set) var subscription: NotificarePushSubscription? {
        get { LocalStorage.subscription }
        set { LocalStorage.subscription = newValue }
    }

    public private(set) var allowedUI: Bool {
        get { LocalStorage.allowedUI }
        set { LocalStorage.allowedUI = newValue }
    }

    public func enableRemoteNotifications(_ completion: @escaping NotificareCallback<Bool>) {
        Task {
            do {
                let result = try await enableRemoteNotifications()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func enableRemoteNotifications() async throws -> Bool {
        try checkPrerequisites()

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = true

        // Request notification authorization options.
        let granted = try await notificationCenter.requestAuthorization(options: authorizationOptions)

        try await updateDeviceSubscription()

        if granted {
            logger.info("User granted permission to receive alerts, badge and sounds.")
            await reloadActionCategories()
        } else {
            logger.info("User did not grant permission to receive alerts, badge and sounds.")
        }

        return granted
    }

    public func disableRemoteNotifications(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await disableRemoteNotifications()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func disableRemoteNotifications() async throws {
        try checkPrerequisites()

        // Keep track of the status in local storage.
        LocalStorage.remoteNotificationsEnabled = false

        try await updateDeviceSubscription(
            transport: .notificare,
            token: nil
        )

        // Unregister from APNS
        await UIApplication.shared.unregisterForRemoteNotifications()

        logger.info("Unregistered from push provider.")
    }

    public func isNotificareNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["x-sender"] as? String == "notificare"
    }

    @available(iOS 16.1, *)
    public func registerLiveActivity(_ activityId: String, token: String, topics: [String], _ completion: @escaping NotificareCallback<Void>) {
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
    public func registerLiveActivity(_ activityId: String, token: String, topics: [String]) async throws {
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
    public func endLiveActivity(_ activityId: String, _ completion: @escaping NotificareCallback<Void>) {
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
    public func endLiveActivity(_ activityId: String) async throws {
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

    private func notifySubscriptionUpdated(_ subscription: NotificarePushSubscription?) {
        DispatchQueue.main.async {
            self.delegate?.notificare(self, didChangeSubscription: subscription)
        }

        _subscriptionStream.value = subscription
    }

    private func notifyAllowedUIUpdated(_ allowedUI: Bool) {
        DispatchQueue.main.async {
            self.delegate?.notificare(self, didChangeNotificationSettings: allowedUI)
        }

        _allowedUIStream.value = allowedUI
    }

    private func checkPrerequisites() throws {
        if !Notificare.shared.isReady {
            logger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.apns.rawValue] == true else {
            logger.warning("Notificare APNS functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.apns.rawValue)
        }
    }

    internal func reloadActionCategories(_ completion: @escaping () -> Void) {
        logger.debug("Reloading action categories.")

        if Notificare.shared.options?.preserveExistingNotificationCategories == true {
            notificationCenter.getNotificationCategories { existingCategories in
                let categories = existingCategories.union(self.loadAvailableCategories())
                self.notificationCenter.setNotificationCategories(categories)

                completion()
            }
        } else {
            let categories = loadAvailableCategories()
            notificationCenter.setNotificationCategories(categories)

            return
        }
    }

    internal func reloadActionCategories() async {
        logger.debug("Reloading action categories.")

        if Notificare.shared.options?.preserveExistingNotificationCategories == true {
            let existingCategories = await notificationCenter.notificationCategories()

            let categories = existingCategories.union(loadAvailableCategories())
            notificationCenter.setNotificationCategories(categories)

            return
        } else {
            let categories = loadAvailableCategories()
            notificationCenter.setNotificationCategories(categories)

            return
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

        Task {
            try? await updateDeviceNotificationSettings()
        }
    }

    private func fetchAttachment(for request: UNNotificationRequest, _ completion: @escaping NotificareCallback<UNNotificationAttachment>) {
        guard let attachment = request.content.userInfo["attachment"] as? [String: Any],
              let uri = attachment["uri"] as? String
        else {
            logger.warning("Could not find an attachment URI. Please ensure you're calling this method with the correct payload.")
            completion(.failure(NotificareError.invalidArgument(message: "Notification request has no attachment URI.")))
            return
        }

        guard let url = URL(string: uri) else {
            logger.warning("Invalid attachment URI. Please ensure it's a valid URL.")
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

                if
                    let mimeType = response.mimeType,
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

    private func updateDeviceSubscription() async throws {
        let token = try await pushTokenRequester.requestToken()

        try await updateDeviceSubscription(
            transport: .apns,
            token: token
        )
    }

    private func updateDeviceSubscription(transport: NotificareTransport, token: String?) async throws {
        logger.debug("Updating push subscription.")

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let previousTransport = self.transport
        let previousSubscription = self.subscription

        if previousTransport == transport && previousSubscription?.token == token {
            logger.debug("Push subscription unmodified. Updating notification settings instead.")
            try await updateDeviceNotificationSettings()
            return
        }

        let isPushCapable = transport != .notificare
        let hasPermission = await hasNotificationPermission()
        let allowedUI = isPushCapable && hasPermission

        let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceSubscription(
            transport: transport,
            subscriptionId: token,
            allowedUI: allowedUI
        )

        try await NotificareRequest.Builder()
            .put("/push/\(device.id)", body: payload)
            .response()

        let subscription = token.map { NotificarePushSubscription(token: $0) }

        self.transport = transport
        self.subscription = subscription
        self.allowedUI = allowedUI

        notifySubscriptionUpdated(subscription)
        notifyAllowedUIUpdated(allowedUI)

        await ensureLoggedPushRegistration()
    }

    private func updateDeviceNotificationSettings() async throws {
        logger.debug("Updating user notification settings.")

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        let previousAllowedUI = self.allowedUI

        let transport = self.transport
        let isPushCapable = transport != nil && transport != .notificare
        let hasPermission = await hasNotificationPermission()
        let allowedUI = isPushCapable && hasPermission

        if previousAllowedUI != allowedUI {
            let payload = NotificareInternals.PushAPI.Payloads.UpdateDeviceNotificationSettings(
                allowedUI: allowedUI
            )

            try await NotificareRequest.Builder()
                .put("/push/\(device.id)", body: payload)
                .response()

            logger.debug("User notification settings updated.")
            self.allowedUI = allowedUI

            notifyAllowedUIUpdated(allowedUI)
        } else {
            logger.debug("User notification settings update skipped, nothing changed.")
        }

        await ensureLoggedPushRegistration()
    }

    private func hasNotificationPermission() async -> Bool {
        let settings = await notificationCenter.notificationSettings()

        var granted = settings.authorizationStatus == .authorized

        if #available(iOS 12.0, *) {
            if settings.authorizationStatus == .provisional {
                granted = true
            }
        }

        return granted
    }

    private func ensureLoggedPushRegistration() async {
        guard allowedUI, LocalStorage.firstRegistration else {
            return
        }

        do {
            // Ensure the flag update is immediate, preventing multiple simulatenous allowedUI updates
            // from triggering the event.
            LocalStorage.firstRegistration = false

            try await Notificare.shared.events().logPushRegistration()
        } catch {
            logger.warning("Failed to log the push registration event.", error: error)
            LocalStorage.firstRegistration = true
        }
    }
}
