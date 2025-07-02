//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Combine
import NotificareKit
import UIKit

internal class NotificareInboxImpl: NSObject, NotificareModule, NotificareInbox {
    private static let addInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.AddInboxItem")
    private static let readInboxItemNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReadInboxItem")
    private static let refreshBadgeNotification = NSNotification.Name(rawValue: "NotificareInboxKit.RefreshBadge")
    private static let reloadInboxNotification = NSNotification.Name(rawValue: "NotificareInboxKit.ReloadInbox")

    public weak var delegate: NotificareInboxDelegate?

    public let itemsStream: AnyPublisher<[NotificareInboxItem], Never>
    public let badgeStream: AnyPublisher<Int, Never>

    public var items: [NotificareInboxItem] {
        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            return []
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            return []
        }

        return cachedItems.compactMap { item in
            guard item.visible && !item.isExpired else {
                return nil
            }

            return NotificareInboxItem(
                id: item.id,
                notification: item.notification,
                time: item.time,
                opened: item.opened,
                expires: item.expires
            )
        }
    }

    public var badge: Int {
        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            return 0
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            return 0
        }

        guard application.inboxConfig?.autoBadge == true else {
            logger.warning("Notificare auto badge functionality is not enabled.")
            return 0
        }

        return LocalStorage.currentBadge
    }

    private let database = InboxDatabase()
    private let cache = InboxCache()
    private var cachedItems: [LocalInboxItem] = []

    private var _badgeStream = CurrentValueSubject<Int, Never>(0)
    private var _itemsStream = CurrentValueSubject<[NotificareInboxItem], Never>([])

    internal override init() {
        itemsStream = _itemsStream
            .map { items in
                items.filter { !$0.isExpired }
            }
            .eraseToAnyPublisher()

        badgeStream = _badgeStream.eraseToAnyPublisher()
    }

    // MARK: - Notificare Module

    internal static let instance = NotificareInboxImpl()

    internal func configure() {
        logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false

        database.configure()

        Task {
            await loadCache()
        }

        // Listen to inbox addition requests.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onAddItemNotification(_:)),
            name: NotificareInboxImpl.addInboxItemNotification,
            object: nil
        )

        // Listen to inbox read requests.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onReadItemNotification(_:)),
            name: NotificareInboxImpl.readInboxItemNotification,
            object: nil
        )

        // Listen to badge refresh requests.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onRefreshBadgeNotification(_:)),
            name: NotificareInboxImpl.refreshBadgeNotification,
            object: nil
        )

        // Listen to inbox reload requests.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onReloadInboxNotification(_:)),
            name: NotificareInboxImpl.reloadInboxNotification,
            object: nil
        )

        // Listen to application did become active events.
        NotificationCenter.default.upsertObserver(
            self,
            selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    internal func clearStorage() async throws {
        try await database.clear()
        LocalStorage.clear()
    }

    internal func launch() async throws {
        sync()
    }

    internal func unlaunch() async throws {
        try await clearLocalInbox()
        clearNotificationCenter()

        try await clearRemoteInbox()

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
    }

    // MARK: - Notificare Inbox

    public func refresh() {
        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application not yet available.")
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
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
    public func refreshBadge() async throws -> Int {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        guard Notificare.shared.application?.inboxConfig?.autoBadge == true else {
            logger.warning("Notificare auto badge functionality is not enabled.")
            throw NotificareInboxError.autoBadgeUnavailable
        }

        do {
            let response = try await fetchRemoteInbox(for: device.id, skip: 0, limit: 1)

            // Keep a cached copy of the current badge.
            LocalStorage.currentBadge = response.unread

            // Update the application badge.
            await setApplicationBadge(response.unread)

            notifyBadgeUpdated(response.unread)

            return response.unread
        } catch {
            logger.error("Failed to refresh the badge.", error: error)
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

    public func open(_ item: NotificareInboxItem) async throws -> NotificareNotification {
        try checkPrerequisites()

        if item.notification.partial {
            let notification = try await Notificare.shared.fetchNotification(item.id)

            if let localItem = await cache.update(item, { $0.notification = notification }) {
                await updateLocalItems()

                do {
                    try await self.database.update(localItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
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

    public func markAsRead(_ item: NotificareInboxItem) async throws {
        try checkPrerequisites()

        do {
            // Send an event to mark the notification as read in the remote inbox.
            try await Notificare.shared.events().logNotificationOpen(item.notification.id)

            // Update the cache.
            if let updatedItem = await cache.update(item, { $0.opened = true }) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
                }
            }

            // No need to keep the item in the notification center.
            Notificare.shared.removeNotificationFromNotificationCenter(item.notification)

            notifyItemsUpdated(self.items)
            _ = try? await refreshBadge()
        } catch {
            logger.warning("Failed to mark item as read.", error: error)
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

    public func markAllAsRead() async throws {
        try checkPrerequisites()

        guard let device = Notificare.shared.device().currentDevice else {
            throw NotificareError.deviceUnavailable
        }

        try await NotificareRequest.Builder()
            .put("/notification/inbox/fordevice/\(device.id)")
            .response()

        // Skip items where nothing changes.
        for item in await cache.items.filter({ !$0.opened && $0.visible }) {
            // Update the cache.
            if let updatedItem = await cache.update(item, { $0.opened = true }) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(item.id)' into the database.", error: error)
                }
            }
        }

        // Clear all items from the notification center.
        clearNotificationCenter()

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
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

    public func remove(_ item: NotificareInboxItem) async throws {
        try checkPrerequisites()

        try await NotificareRequest.Builder()
            .delete("/notification/inbox/\(item.id)")
            .response()

        try await database.remove(id: item.id)
        await cache.removeAll(id: item.id)
        await updateLocalItems()

        Notificare.shared.removeNotificationFromNotificationCenter(item.notification)

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
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

    public func clear() async throws {
        try checkPrerequisites()

        try await clearRemoteInbox()

        try await clearLocalInbox()
        clearNotificationCenter()

        notifyItemsUpdated(self.items)
        _ = try? await refreshBadge()
    }

    // MARK: - Internal API

    private func notifyItemsUpdated(_ items: [NotificareInboxItem]) {
        DispatchQueue.main.async {
            self.delegate?.notificare(self, didUpdateInbox: self.items)
        }

        _itemsStream.value = items
    }

    private func notifyBadgeUpdated(_ badge: Int) {
        DispatchQueue.main.async {
            self.delegate?.notificare(self, didUpdateBadge: badge)
        }

        _badgeStream.value = badge
    }

    private func checkPrerequisites() throws {
        guard Notificare.shared.isReady else {
            logger.warning("Notificare is not ready yet.")
            throw NotificareError.notReady
        }

        guard let application = Notificare.shared.application else {
            logger.warning("Notificare application is not yet available.")
            throw NotificareError.applicationUnavailable
        }

        guard application.services[NotificareApplication.ServiceKey.inbox.rawValue] == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }

        guard application.inboxConfig?.useInbox == true else {
            logger.warning("Notificare inbox functionality is not enabled.")
            throw NotificareError.serviceUnavailable(service: NotificareApplication.ServiceKey.inbox.rawValue)
        }
    }

    private func sync() {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("No device registered yet. Skipping...")
            return
        }

        Task {
            guard let firstItem = await cache.items.first else {
                logger.debug("The local inbox contains no items. Checking remotely.")
                reloadInbox()

                return
            }

            do {
                let timestamp = Int64(firstItem.time.timeIntervalSince1970 * 1000)
                logger.debug("Checking if the inbox has been modified since \(timestamp).")

                _ = try await fetchRemoteInbox(for: device.id, since: timestamp)

                logger.info("The inbox has been modified. Performing a full sync.")
                reloadInbox()
            } catch {
                if case let NotificareNetworkError.validationError(response, _, _) = error {
                    if response.statusCode == 304 {
                        logger.debug("The inbox has not been modified. Proceeding with locally stored data.")

                        _ = try? await refreshBadge()
                        notifyItemsUpdated(self.items)

                        return
                    }
                }

                logger.error("Failed to fetch the remote inbox.", error: error)
            }
        }
    }

    private func reloadInbox() {
        Task {
            do {
                try await clearLocalInbox()
                try await requestRemoteInboxItems()
            } catch {
                logger.error("Failed to reload the inbox.", error: error)
            }
        }
    }

    private func loadCache() async {
        do {
            let items = try await database.find()
            await cache.set(items)
            await updateLocalItems()
        } catch {
            logger.error("Failed to query the local database.", error: error)
        }
    }

    private func addToLocalInbox(_ item: LocalInboxItem) async throws {
        // NOTE: Remove duplicates for a given notification before adding the item to the inbox.
        // When receiving a triggered notification, we may receive it more than once.
        await cache.removeAll(notificationId: item.notification.id)
        try await database.remove(notificationId: item.notification.id)

        do {
            try await database.add(item)
            await cache.add(item)
        } catch {
            logger.warning("Unable to encode inbox item '\(item.id)' into the database.", error: error)
        }

        await updateLocalItems()
    }

    private func clearLocalInbox() async throws {
        try await database.clear()
        await cache.removeAll()
        await updateLocalItems()
    }

    private func removeExpiredItemsFromNotificationCenter() async {
        await cache.items.forEach { item in
            if item.isExpired {
                Notificare.shared.removeNotificationFromNotificationCenter(item.notification.id)
            }
        }
    }

    private func clearNotificationCenter() {
        logger.debug("Removing all messages from the notification center.")
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

    // TODO: Refactor out recursion.
    private func requestRemoteInboxItems(step: Int = 0) async throws {
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Notificare has not been configured yet.")
            throw NotificareError.deviceUnavailable
        }

        let response = try await fetchRemoteInbox(for: device.id, skip: step * 100, limit: 100)

        // Add all items to the database.
        for item in response.inboxItems {
            try await addToLocalInbox(item.toLocal())
        }

        if response.count > (step + 1) * 100 {
            logger.debug("Loading more inbox items.")
            try await requestRemoteInboxItems(step: step + 1)
        } else {
            logger.debug("Done loading inbox items.")

            notifyItemsUpdated(self.items)
            _ = try? await self.refreshBadge()
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

    private func updateLocalItems() async {
        cachedItems = await cache.items
    }

    @MainActor
    private func setApplicationBadge(_ badge: Int) {
        UIApplication.shared.applicationIconBadgeNumber = badge
    }

    // MARK: - NotificationCenter events

    @objc private func onAddItemNotification(_ notificationSignal: Notification) {
        logger.debug("Received a signal to add an item to the inbox.")

        guard let userInfo = notificationSignal.userInfo,
              let notification = userInfo["notification"] as? NotificareNotification,
              let inboxItemId = userInfo["inboxItemId"] as? String,
              let inboxItemVisible = userInfo["inboxItemVisible"] as? Bool
        else {
            logger.warning("Unable to handle 'add to inbox' signal.")
            return
        }

        Task {
            do {
                try await addToLocalInbox(
                    LocalInboxItem(
                        id: inboxItemId,
                        notification: notification,
                        time: Date(),
                        opened: false,
                        visible: inboxItemVisible,
                        expires: userInfo["inboxItemExpires"] as? Date
                    )
                )
            } catch {
                logger.warning("Unable to add inbox item to local cache.", error: error)
            }

            _ = try? await refreshBadge()
            notifyItemsUpdated(self.items)
        }
    }

    @objc private func onReadItemNotification(_ notification: Notification) {
        logger.debug("Received a signal to mark an item as read.")

        guard let userInfo = notification.userInfo, let inboxItemId = userInfo["inboxItemId"] as? String else {
            logger.warning("Unable to handle the notification read request.")
            return
        }

        Task {
            // Update the cache.
            if let updatedItem = await cache.update(inboxItemId, { $0.opened = true }) {
                await updateLocalItems()

                do {
                    // Update the database.
                    try await self.database.update(updatedItem)
                } catch {
                    logger.warning("Unable to encode updated inbox item '\(inboxItemId)' into the database.", error: error)
                }
            }

            _ = try? await refreshBadge()
            notifyItemsUpdated(self.items)
        }
    }

    @objc private func onRefreshBadgeNotification(_: Notification) {
        logger.debug("Received a signal to refresh the badge.")

        Task {
            try? await refreshBadge()
        }
    }

    @objc private func onReloadInboxNotification(_: Notification) {
        logger.debug("Received a signal to reload the inbox.")
        reloadInbox()
    }

    @objc private func onApplicationDidBecomeActiveNotification(_: Notification) {
        // Don't check anything unless we're ready.
        guard Notificare.shared.isReady else {
            return
        }

        // Wait a bit before checking.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task {
                // Clear expired items from the notification center.
                await self.removeExpiredItemsFromNotificationCenter()

                guard let device = Notificare.shared.device().currentDevice else {
                    logger.warning("Notificare has not been configured yet.")
                    return
                }

                guard await !self.cache.items.isEmpty else {
                    logger.debug("The inbox is empty. No need to do a full sync.")
                    return
                }

                do {
                    let response = try await self.fetchRemoteInbox(for: device.id, skip: 0, limit: 1)

                    let total = self.items.count
                    let unread = self.items.filter { !$0.opened }.count

                    if response.count != total || response.unread != unread {
                        logger.debug("The inbox needs an update. The count/unread don't match with the local data.")
                        self.reloadInbox()
                    } else {
                        logger.debug("The inbox doesn't need an update. Proceeding as is.")
                    }
                } catch {
                    logger.error("Failed to compare the local and remote unread counts.", error: error)
                }
            }
        }
    }
}
