//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

internal class NotificareInboxImpl: NSObject, NotificareModule, NotificareInbox {
    private static let addInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.AddInboxItem")
    private static let readInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReadInboxItem")
    private static let refreshBadgeNotification = NSNotification.Name(rawValue: "NotificareInboxKit.RefreshBadge")
    private static let reloadInboxNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReloadInbox")

    public weak var delegate: NotificareInboxDelegate?

    public var items: [NotificareInboxItem] {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            return []
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            return []
        }

        return cachedEntities
            .filter { $0.visible && !$0.expired }
            .compactMap { entity in
                do {
                    return try entity.toModel()
                } catch {
                    NotificareLogger.warning("Unable to decode inbox item '\(entity.id ?? "")' from the database.", error: error)
                    return nil
                }
            }
    }

    public var badge: Int {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            return 0
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            return 0
        }

        guard application.inboxConfig?.autoBadge == true else {
            NotificareLogger.warning("Notificare auto badge functionality is not enabled.")
            return 0
        }

        return LocalStorage.currentBadge
    }

    private let database = InboxDatabase()
    private var _cachedEntities: [InboxItemEntity] = []
    private var cachedEntities: [InboxItemEntity] {
        get { _cachedEntities }
        set {
            // NOTE: Make sure the cached item are always sorted by date descending.
            // The most recent one if important to be the first as the sync logic relies on it.
            _cachedEntities = newValue.sorted(by: { lhs, rhs -> Bool in
                lhs.time!.compare(rhs.time!) == .orderedDescending
            })
        }
    }

    // MARK: - Notificare Module

    static let instance = NotificareInboxImpl()

    func configure() {
        database.configure()
        loadCachedItems()

        // Listen to inbox addition requests.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAddItemNotification(_:)),
                                               name: NotificareInboxImpl.addInboxItemNotification,
                                               object: nil)

        // Listen to inbox read requests.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReadItemNotification(_:)),
                                               name: NotificareInboxImpl.readInboxItemNotification,
                                               object: nil)

        // Listen to badge refresh requests.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onRefreshBadgeNotification(_:)),
                                               name: NotificareInboxImpl.refreshBadgeNotification,
                                               object: nil)

        // Listen to inbox reload requests.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReloadInboxNotification(_:)),
                                               name: NotificareInboxImpl.reloadInboxNotification,
                                               object: nil)

        // Listen to application did become active events.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func launch() async throws {
        sync()
    }

    func unlaunch() async throws {
        clearLocalInbox()
        clearNotificationCenter()

        try await clearRemoteInbox()

        DispatchQueue.main.async {
            self.delegate?.notificare(self, didUpdateInbox: self.items)
        }

        try await refreshBadge()
    }

    // MARK: - Notificare Inbox

    public func refresh() {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application not yet available.")
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            return
        }

        reloadInbox()
    }

    public func refreshBadge(_ completion: @escaping NotificareCallback<Int>) {
        Task {
            do {
                let result = try await refreshBadge()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func refreshBadge() async throws -> Int {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        guard Notificare.shared.application?.inboxConfig?.autoBadge == true else {
            NotificareLogger.warning("Notificare auto badge functionality is not enabled.")
            throw NotificareInboxError.autoBadgeUnavailable
        }

        do {
            let response = try await fetchRemoteInbox(for: device.id, skip: 0, limit: 1)

            // Keep a cached copy of the current badge.
            LocalStorage.currentBadge = response.unread

            // Update the application badge.
            await setApplicationBadge(response.unread)

            DispatchQueue.main.async {
                // Notify the delegate.
                self.delegate?.notificare(self, didUpdateBadge: response.unread)
            }

            return response.unread
        } catch {
            NotificareLogger.error("Failed to refresh the badge.", error: error)
            throw error
        }
    }

    public func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        Task {
            do {
                let result = try await open(item)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func open(_ item: NotificareInboxItem) async throws -> NotificareNotification {
        try checkPrerequisites()

        if item.notification.partial {
            let notification = try await Notificare.shared.fetchNotification(item.id)

            // Update the entity in the database.
            if let entity = cachedEntities.first(where: { $0.id == item.id }) {
                do {
                    try entity.setNotification(notification)
                    database.saveChanges()
                } catch {
                    NotificareLogger.warning("Unable to encode updated inbox item '\(item.id)' into the database.",
                                             error: error)
                }
            }

            // Mark the item as read & send a notification open event.
            try await markAsRead(item)
            return notification
        } else {
            // Mark the item as read & send a notification open event.
            try await markAsRead(item)
            return item.notification
        }
    }

    public func markAsRead(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await markAsRead(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func markAsRead(_ item: NotificareInboxItem) async throws {
        try checkPrerequisites()

        do {
            // Send an event to mark the notification as read in the remote inbox.
            try await Notificare.shared.events().logNotificationOpen(item.notification.id)
            // Mark entities as read.
            cachedEntities
                .filter { $0.id == item.id }
                .forEach { $0.opened = true }

            // Persist the changes to the database.
            database.saveChanges()

            // No need to keep the item in the notification center.
            Notificare.shared.removeNotificationFromNotificationCenter(item.notification)

            DispatchQueue.main.async {
                // Notify the delegate.
                self.delegate?.notificare(self, didUpdateInbox: self.items)
            }

            // Refresh the badge if applicable.
            try await refreshBadge()
        } catch {
            NotificareLogger.warning("Failed to mark item as read.", error: error)
            throw error
        }
    }

    public func markAllAsRead(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await markAllAsRead()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func markAllAsRead() async throws {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        try await NotificareRequest.Builder()
            .put("/notification/inbox/fordevice/\(device.id)")
            .response()

        cachedEntities
            .filter { !$0.opened && $0.visible }
            .forEach { entity in
                // Mark entity as read.
                entity.opened = true
            }

        // Persist the changes to the database.
        database.saveChanges()

        // Clear all items from the notification center.
        clearNotificationCenter()

        DispatchQueue.main.async {
            // Notify the delegate.
            self.delegate?.notificare(self, didUpdateInbox: self.items)
        }

        // Refresh the badge if applicable.
        try await refreshBadge()
    }

    public func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await remove(item)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func remove(_ item: NotificareInboxItem) async throws {
        try checkPrerequisites()

        try await NotificareRequest.Builder()
            .delete("/notification/inbox/\(item.id)")
            .response()

        if let entity = cachedEntities.first(where: { $0.id == item.id }),
           let index = cachedEntities.firstIndex(of: entity)
        {
            database.remove(entity)
            cachedEntities.remove(at: index)

            Notificare.shared.removeNotificationFromNotificationCenter(item.notification)
        }

        DispatchQueue.main.async {
            // Notify the delegate.
            self.delegate?.notificare(self, didUpdateInbox: self.items)
        }

        // Refresh the badge if applicable.
        try await refreshBadge()
    }

    public func clear(_ completion: @escaping NotificareCallback<Void>) {
        Task {
            do {
                try await clear()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func clear() async throws {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        try await NotificareRequest.Builder()
            .delete("/notification/inbox/fordevice/\(device.id)")
            .response()

        clearLocalInbox()
        clearNotificationCenter()

        DispatchQueue.main.async {
            // Notify the delegate.
            self.delegate?.notificare(self, didUpdateInbox: self.items)
        }

        try await refreshBadge()
    }

    // MARK: - Internal API

    private func checkPrerequisites() throws {
        guard Notificare.shared.isReady else {
            NotificareLogger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.inbox.rawValue] == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }
    }

    private func sync() {
        guard let device = Notificare.shared.device().currentDevice else {
            NotificareLogger.warning("No device registered yet. Skipping...")
            return
        }

        guard let firstItem = cachedEntities.first else {
            NotificareLogger.debug("The local inbox contains no items. Checking remotely.")
            reloadInbox()

            return
        }

        let timestamp = Int64(firstItem.time!.timeIntervalSince1970 * 1000)

        NotificareLogger.debug("Checking if the inbox has been modified since \(timestamp).")

        Task {
            do {
                _ = try await fetchRemoteInbox(for: device.id, since: timestamp)

                NotificareLogger.info("The inbox has been modified. Performing a full sync.")
                self.reloadInbox()
            } catch {
                if case let NotificareNetworkError.validationError(response, _, _) = error {
                    if response.statusCode == 304 {
                        NotificareLogger.debug("The inbox has not been modified. Proceeding with locally stored data.")

                        try await self.refreshBadge()

                        DispatchQueue.main.async {
                            self.delegate?.notificare(self, didUpdateInbox: self.items)
                        }
                        return
                    }
                }
                NotificareLogger.error("Failed to fetch the remote inbox.", error: error)
            }
        }
    }

    private func reloadInbox() {
        clearLocalInbox()
        requestRemoteInboxItems()
    }

    private func loadCachedItems() {
        do {
            cachedEntities = try database.find()
        } catch {
            NotificareLogger.error("Failed to query the local database.", error: error)
        }
    }

    private func addToLocalInbox(_ item: NotificareInboxItem, visible: Bool) {
        // NOTE: Remove duplicates for a given notification before adding the item to the inbox.
        // When receiving a triggered notification, we may receive it more than once.
        cachedEntities
            .filter { $0.notificationId == item.notification.id }
            .forEach { entity in
                database.remove(entity)

                if let index = cachedEntities.firstIndex(of: entity) {
                    cachedEntities.remove(at: index)
                }
            }

        do {
            let entity = try database.add(item, visible: visible)
            cachedEntities.append(entity)
        } catch {
            NotificareLogger.warning("Unable to encode inbox item '\(item.id)' into the database.", error: error)
        }
    }

    private func clearLocalInbox() {
        do {
            try database.clear()
            cachedEntities.removeAll()
        } catch {
            NotificareLogger.error("Failed to clear the local inbox.", error: error)
        }
    }

    private func removeExpiredItemsFromNotificationCenter() {
        for entity in cachedEntities {
            if entity.expired, let notificationId = entity.notificationId {
                Notificare.shared.removeNotificationFromNotificationCenter(notificationId)
            }
        }
    }

    private func clearNotificationCenter() {
        NotificareLogger.debug("Removing all messages from the notification center.")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func fetchRemoteInbox(for deviceId: String, since: Int64? = nil, skip: Int = 0, limit: Int = 100) async throws -> NotificareInternals.PushAPI.Responses.RemoteInbox {
        let request = NotificareRequest.Builder()
            .get("/notification/inbox/fordevice/\(deviceId)")
            .query(name: "skip", value: String(format: "%d", skip))
            .query(name: "limit", value: String(format: "%d", limit))

        if let since = since {
            _ = request.query(name: "ifModifiedSince", value: "\(since)")
        }

        return try await request.responseDecodable(NotificareInternals.PushAPI.Responses.RemoteInbox.self)
    }

    private func requestRemoteInboxItems(step: Int = 0) {
        guard let device = Notificare.shared.device().currentDevice else {
            NotificareLogger.warning("Notificare has not been configured yet.")
            return
        }

        Task {
            do {
                let response = try await fetchRemoteInbox(for: device.id, skip: step * 100, limit: 100)

                // Add all items to the database.
                for item in response.inboxItems {
                    self.addToLocalInbox(item.toModel(), visible: item.visible)
                }

                if response.count > (step + 1) * 100 {
                    NotificareLogger.debug("Loading more inbox items.")
                    self.requestRemoteInboxItems(step: step + 1)
                } else {
                    NotificareLogger.debug("Done loading inbox items.")

                    DispatchQueue.main.async {
                        // Notify the delegate.
                        self.delegate?.notificare(self, didUpdateInbox: self.items)
                    }

                    // Refresh the badge if applicable.
                    try await self.refreshBadge()
                }
            } catch {
                NotificareLogger.error("Failed to fetch inbox items.", error: error)
            }
        }
    }

    private func clearRemoteInbox() async throws {
        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        try await NotificareRequest.Builder()
            .delete("/notification/inbox/fordevice/\(device.id)")
            .response()
    }

    @MainActor
    private func setApplicationBadge(_ badge: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badge
    }

    // MARK: - NotificationCenter events

    @objc private func onAddItemNotification(_ notificationSignal: Notification) {
        NotificareLogger.debug("Received a signal to add an item to the inbox.")

        guard let userInfo = notificationSignal.userInfo,
              let notification = userInfo["notification"] as? NotificareNotification,
              let inboxItemId = userInfo["inboxItemId"] as? String,
              let inboxItemVisible = userInfo["inboxItemVisible"] as? Bool
        else {
            NotificareLogger.warning("Unable to handle 'add to inbox' signal.")
            return
        }

        addToLocalInbox(
            NotificareInboxItem(
                id: inboxItemId,
                notification: notification,
                time: Date(),
                opened: false,
                expires: userInfo["inboxItemExpires"] as? Date
            ),
            visible: inboxItemVisible
        )

        refreshBadge { _ in
            DispatchQueue.main.async {
                self.delegate?.notificare(self, didUpdateInbox: self.items)
            }
        }
    }

    @objc private func onReadItemNotification(_ notification: Notification) {
        NotificareLogger.debug("Received a signal to mark an item as read.")

        guard let userInfo = notification.userInfo, let inboxItemId = userInfo["inboxItemId"] as? String else {
            NotificareLogger.warning("Unable to handle the notification read request.")
            return
        }

        // Mark entities as read.
        cachedEntities
            .filter { $0.id == inboxItemId }
            .forEach { $0.opened = true }

        // Persist the changes to the database.
        database.saveChanges()

        refreshBadge { _ in
            DispatchQueue.main.async {
                self.delegate?.notificare(self, didUpdateInbox: self.items)
            }
        }
    }

    @objc private func onRefreshBadgeNotification(_: Notification) {
        NotificareLogger.debug("Received a signal to refresh the badge.")
        refreshBadge { _ in }
    }

    @objc private func onReloadInboxNotification(_: Notification) {
        NotificareLogger.debug("Received a signal to reload the inbox.")
        reloadInbox()
    }

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        // Don't check anything unless we're ready.
        guard Notificare.shared.isReady else {
            return
        }

        // Wait a bit before checking.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Clear expired items from the notification center.
            self.removeExpiredItemsFromNotificationCenter()

            guard let device = Notificare.shared.device().currentDevice else {
                NotificareLogger.warning("Notificare has not been configured yet.")
                return
            }

            guard !self.cachedEntities.isEmpty else {
                NotificareLogger.debug("The inbox is empty. No need to do a full sync.")
                return
            }

            Task {
                guard let response = try? await self.fetchRemoteInbox(for: device.id, skip: 0, limit: 1) else {
                    return
                }

                let total = self.items.count
                let unread = self.items.filter { !$0.opened }.count

                if response.count != total || response.unread != unread {
                    NotificareLogger.debug("The inbox needs an update. The count/unread don't match with the local data.")
                    self.reloadInbox()
                } else {
                    NotificareLogger.debug("The inbox doesn't need an update. Proceeding as is.")
                }
            }
        }
    }
}
