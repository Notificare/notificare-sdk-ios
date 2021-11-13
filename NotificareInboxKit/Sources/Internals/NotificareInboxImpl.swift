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

    internal static let instance = NotificareInboxImpl()

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

        return visibleItems
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

    private var visibleItems: [NotificareInboxItem] {
        cachedEntities
            .map { $0.toModel() }
            .filter { $0.visible && !$0.expired }
    }

    // MARK: - Notificare Module

    public static func configure() {
        instance.database.configure()

        // Listen to inbox addition requests.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onAddItemNotification(_:)),
                                               name: addInboxItemNotification,
                                               object: nil)

        // Listen to inbox read requests.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onReadItemNotification(_:)),
                                               name: readInboxItemNotification,
                                               object: nil)

        // Listen to badge refresh requests.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onRefreshBadgeNotification(_:)),
                                               name: refreshBadgeNotification,
                                               object: nil)

        // Listen to inbox reload requests.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onReloadInboxNotification(_:)),
                                               name: reloadInboxNotification,
                                               object: nil)

        // Listen to application did become active events.
        NotificationCenter.default.addObserver(instance,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public static func launch(_ completion: @escaping NotificareCallback<Void>) {
        if UIApplication.shared.applicationState == .active {
            instance.sync()
        }

        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping NotificareCallback<Void>) {
        instance.clearLocalInbox()
        completion(.success(()))
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
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        guard Notificare.shared.application?.inboxConfig?.autoBadge == true else {
            NotificareLogger.warning("Notificare auto badge functionality is not enabled.")
            completion(.failure(NotificareInboxError.autoBadgeUnavailable))
            return
        }

        fetchRemoteInbox(for: device.id, skip: 0, limit: 1) { result in
            switch result {
            case let .success(response):
                // Keep a cached copy of the current badge.
                LocalStorage.currentBadge = response.unread

                // Update the application badge.
                UIApplication.shared.applicationIconBadgeNumber = response.unread

                // Notify the delegate.
                self.delegate?.notificare(self, didUpdateBadge: response.unread)

                completion(.success(response.unread))
            case let .failure(error):
                NotificareLogger.error("Failed to refresh the badge.", error: error)
                completion(.failure(error))
            }
        }
    }

    public func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<NotificareNotification>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        // Remove the item from the notification center.
        Notificare.shared.removeNotificationFromNotificationCenter(item.notification)

        if item.notification.partial {
            Notificare.shared.fetchNotification(item.notification.id) { result in
                switch result {
                case let .success(notification):
                    // Update the entity in the database.
                    if let entity = self.cachedEntities.first(where: { $0.id == item.id }) {
                        entity.setNotification(notification)
                        self.database.saveChanges()
                    }

                    // Mark the item as read & send a notification open event.
                    self.markAsRead(item) { result in
                        switch result {
                        case .success:
                            completion(.success(notification))

                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }

                case let .failure(error):
                    completion(.failure(error))
                }
            }
        } else {
            // Mark the item as read & send a notification open event.
            markAsRead(item) { result in
                switch result {
                case .success:
                    completion(.success(item.notification))

                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    public func markAsRead(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        // Send an event to mark the notification as read in the remote inbox.
        Notificare.shared.events().logNotificationOpen(item.notification.id) { result in
            switch result {
            case .success:
                // Mark entities as read.
                self.cachedEntities
                    .filter { $0.id == item.id }
                    .forEach { $0.opened = true }

                // Persist the changes to the database.
                self.database.saveChanges()

                // No need to keep the item in the notification center.
                Notificare.shared.removeNotificationFromNotificationCenter(item.notification)

                // Notify the delegate.
                self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)

                // Refresh the badge if applicable.
                self.refreshBadge { _ in }

                completion(.success(()))

            case let .failure(error):
                NotificareLogger.warning("Failed to mark item as read.", error: error)
                completion(.failure(error))
            }
        }
    }

    public func markAllAsRead(_ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .put("/notification/inbox/fordevice/\(device.id)")
            .response { result in
                switch result {
                case .success:
                    self.cachedEntities
                        .filter { !$0.opened && $0.visible }
                        .forEach { entity in
                            // Mark entity as read.
                            entity.opened = true

                            // No need to keep the item in the notification center.
                            Notificare.shared.removeNotificationFromNotificationCenter(entity.toModel().notification)
                        }

                    // Persist the changes to the database.
                    self.database.saveChanges()

                    // Clear all items from the notification center.
                    self.clearNotificationCenter()

                    // Notify the delegate.
                    self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)

                    // Refresh the badge if applicable.
                    self.refreshBadge { _ in
                        completion(.success(()))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        NotificareRequest.Builder()
            .delete("/notification/inbox/\(item.id)")
            .response { result in
                switch result {
                case .success:
                    if let entity = self.cachedEntities.first(where: { $0.id == item.id }),
                       let index = self.cachedEntities.firstIndex(of: entity)
                    {
                        self.database.remove(entity)
                        self.cachedEntities.remove(at: index)

                        Notificare.shared.removeNotificationFromNotificationCenter(item.notification)
                    }

                    // Notify the delegate.
                    self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)

                    // Refresh the badge if applicable.
                    self.refreshBadge { _ in
                        completion(.success(()))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }

    public func clear(_ completion: @escaping NotificareCallback<Void>) {
        do {
            try checkPrerequisites()
        } catch {
            completion(.failure(error))
            return
        }

        guard let device = Notificare.shared.device().currentDevice else {
            completion(.failure(NotificareError.deviceUnavailable))
            return
        }

        NotificareRequest.Builder()
            .delete("/notification/inbox/fordevice/\(device.id)")
            .response { result in
                switch result {
                case .success:
                    self.clearLocalInbox()
                    self.clearNotificationCenter()

                    // Notify the delegate.
                    self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)

                    self.refreshBadge { _ in
                        completion(.success(()))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
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
            NotificareLogger.warning("Notificare has not been configured yet.")
            return
        }

        loadCachedItems()

        guard let firstItem = cachedEntities.first else {
            NotificareLogger.debug("The local inbox contains no items. Checking remotely.")
            reloadInbox()

            return
        }

        let timestamp = Int64(firstItem.time!.timeIntervalSince1970 * 1000)

        NotificareLogger.debug("Checking if the inbox has been modified since \(timestamp).")
        fetchRemoteInbox(for: device.id, since: timestamp) { result in
            switch result {
            case .success:
                NotificareLogger.info("The inbox has been modified. Performing a full sync.")
                self.reloadInbox()

            case let .failure(error):
                if case let NotificareNetworkError.validationError(response, _, _) = error {
                    if response.statusCode == 304 {
                        NotificareLogger.debug("The inbox has not been modified. Proceeding with locally stored data.")
                        self.refreshBadge { _ in
                            self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)
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
            let entities = try database.find()
            cachedEntities = entities
        } catch {
            NotificareLogger.error("Failed to query the local database.", error: error)
            fatalError("Failed to query the local database.")
        }
    }

    private func addToLocalInbox(_ item: NotificareInboxItem) {
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

        let entity = database.add(item)
        cachedEntities.append(entity)
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
        cachedEntities
            .map { $0.toModel() }
            .forEach { item in
                if item.expired {
                    Notificare.shared.removeNotificationFromNotificationCenter(item.notification)
                }
            }
    }

    private func clearNotificationCenter() {
        NotificareLogger.debug("Removing all messages from the notification center.")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func fetchRemoteInbox(for deviceId: String, since: Int64? = nil, skip: Int = 0, limit: Int = 100, _ completion: @escaping NotificareCallback<NotificareInternals.PushAPI.Responses.RemoteInbox>) {
        let request = NotificareRequest.Builder()
            .get("/notification/inbox/fordevice/\(deviceId)")
            .query(name: "skip", value: String(format: "%d", skip))
            .query(name: "limit", value: String(format: "%d", limit))

        if let since = since {
            _ = request.query(name: "ifModifiedSince", value: "\(since)")
        }

        request.responseDecodable(NotificareInternals.PushAPI.Responses.RemoteInbox.self, completion)
    }

    private func requestRemoteInboxItems(step: Int = 0) {
        guard let device = Notificare.shared.device().currentDevice else {
            NotificareLogger.warning("Notificare has not been configured yet.")
            return
        }

        fetchRemoteInbox(for: device.id, skip: step * 100, limit: 100) { result in
            switch result {
            case let .success(response):
                // Add all items to the database.
                response.inboxItems.forEach { item in
                    self.addToLocalInbox(NotificareInboxItem(remote: item))
                }

                if response.count > (step + 1) * 100 {
                    NotificareLogger.debug("Loading more inbox items.")
                    self.requestRemoteInboxItems(step: step + 1)
                } else {
                    NotificareLogger.debug("Done loading inbox items.")

                    // Notify the delegate.
                    self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)

                    // Refresh the badge if applicable.
                    self.refreshBadge { _ in }
                }
            case let .failure(error):
                NotificareLogger.error("Failed to fetch inbox items.", error: error)
            }
        }
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
                visible: inboxItemVisible,
                expires: userInfo["inboxItemExpires"] as? Date
            )
        )

        refreshBadge { _ in
            self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)
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
            self.delegate?.notificare(self, didUpdateInbox: self.visibleItems)
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

            self.fetchRemoteInbox(for: device.id, skip: 0, limit: 1) { result in
                switch result {
                case let .success(response):
                    let total = self.visibleItems.count
                    let unread = self.visibleItems.filter { !$0.opened }.count

                    if response.count != total || response.unread != unread {
                        NotificareLogger.debug("The inbox needs an update. The count/unread don't match with the local data.")
                        self.reloadInbox()
                    } else {
                        NotificareLogger.debug("The inbox doesn't need an update. Proceeding as is.")
                    }

                case .failure:
                    break
                }
            }
        }
    }
}
