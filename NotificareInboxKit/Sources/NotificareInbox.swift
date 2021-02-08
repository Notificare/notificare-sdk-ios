//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit
import UIKit

public typealias NotificareInboxCallback<T> = (Result<T, Error>) -> Void

public class NotificareInbox: NSObject, NotificareModule {
    public static let shared = NotificareInbox()

    public weak var delegate: NotificareInboxDelegate?

    public var items: [NotificareInboxItem] {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application is not yet available.")
            return []
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
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
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            return 0
        }

        guard application.inboxConfig?.autoBadge == true else {
            NotificareLogger.warning("Notificare auto badge funcionality is not enabled.")
            return 0
        }

        return NotificareUserDefaults.currentBadge
    }

    private let database = InboxDatabase()
    private var _cachedEntities: [InboxItemEntity] = []
    private var cachedEntities: [InboxItemEntity] {
        get { _cachedEntities }
        set {
            // NOTE: Make sure the cached item are always sorted by date descending.
            // The most recent one if important to be the first as the sync logic relies on it.
            _cachedEntities = newValue.sorted(by: { (lhs, rhs) -> Bool in
                lhs.time!.compare(rhs.time!) == .orderedDescending
            })
        }
    }

    private var visibleItems: [NotificareInboxItem] {
        cachedEntities
            .map { $0.toModel() }
            .filter { $0.visible && !$0.expired }
    }

    // MARK: Notificare module

    public static func configure(applicationKey _: String, applicationSecret _: String) {
        NotificareInbox.shared.database.configure()

        // Listen to inbox addition requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(onAddItemNotification(_:)),
                                               name: NotificareDefinitions.InternalNotification.addInboxItem,
                                               object: nil)

        // Listen to inbox read requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(onReadItemNotification(_:)),
                                               name: NotificareDefinitions.InternalNotification.readInboxItem,
                                               object: nil)

        // Listen to badge refresh requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(onRefreshBadgeNotification(_:)),
                                               name: NotificareDefinitions.InternalNotification.refreshBadge,
                                               object: nil)

        // Listen to inbox reload requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(onReloadInboxNotification(_:)),
                                               name: NotificareDefinitions.InternalNotification.reloadInbox,
                                               object: nil)

        // Listen to application did become active events.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(onApplicationDidBecomeActiveNotification(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    public static func launch(_ completion: @escaping NotificareInboxCallback<Void>) {
        NotificareInbox.shared.sync()
        completion(.success(()))
    }

    public static func unlaunch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        NotificareInbox.shared.clear(completion)
    }

    // MARK: - Public API

    public func refresh() {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application not yet available.")
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            return
        }

        reloadInbox()
    }

    public func refreshBadge(_ completion: @escaping NotificareInboxCallback<Int>) {
        guard let application = Notificare.shared.application,
              let api = Notificare.shared.pushApi,
              let device = Notificare.shared.deviceManager.currentDevice
        else {
            NotificareLogger.warning("Notificare application not yet available.")
            completion(.failure(NotificareError.notReady))
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            completion(.failure(NotificareInboxError.inboxUnavailable))
            return
        }

        guard application.inboxConfig?.autoBadge == true else {
            NotificareLogger.warning("Notificare auto badge funcionality is not enabled.")
            completion(.failure(NotificareInboxError.autoBadgeUnavailable))
            return
        }

        api.getInbox(for: device.id, skip: 0, limit: 1) { result in
            switch result {
            case let .success(response):
                // Keep a cached copy of the current badge.
                NotificareUserDefaults.currentBadge = response.unread

                // Update the application badge.
                UIApplication.shared.applicationIconBadgeNumber = response.unread

                // Notify the delegate.
                NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateBadge: response.unread)

                completion(.success(response.unread))
            case let .failure(error):
                NotificareLogger.error("Failed to refresh the badge: \(error)")
                completion(.failure(error))
            }
        }
    }

    public func open(_ item: NotificareInboxItem, _ completion: @escaping NotificareInboxCallback<NotificareNotification>) {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application not yet available.")
            completion(.failure(NotificareError.notReady))
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            completion(.failure(NotificareInboxError.inboxUnavailable))
            return
        }

        // Remove the item from the notification center.
        removeItemFromNotificationCenter(item)

        Notificare.shared.fetchNotification(item.notificationId) { result in
            switch result {
            case let .success(notification):
                // Mark the item as read & send a notification open event.
                self.markAsRead(item)

                completion(.success(notification))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func markAsRead(_ item: NotificareInboxItem) {
        guard let application = Notificare.shared.application else {
            NotificareLogger.warning("Notificare application not yet available.")
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            return
        }

        // Send an event to mark the notification as read in the remote inbox.
        Notificare.shared.eventsManager.logNotificationOpen(item.notificationId)

        // Mark entities as read.
        cachedEntities
            .filter { $0.id == item.id }
            .forEach { $0.opened = true }

        // Persist the changes to the database.
        database.saveChanges()

        // No need to keep the item in the notification center.
        removeItemFromNotificationCenter(item)

        // Notify the delegate.
        NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: visibleItems)

        // Refresh the badge if applicable.
        refreshBadge { _ in }
    }

    public func markAllAsRead(_ completion: @escaping NotificareInboxCallback<Void>) {
        guard let application = Notificare.shared.application,
              let api = Notificare.shared.pushApi,
              let device = Notificare.shared.deviceManager.currentDevice
        else {
            NotificareLogger.warning("Notificare application not yet available.")
            completion(.failure(NotificareError.notReady))
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            completion(.failure(NotificareInboxError.inboxUnavailable))
            return
        }

        api.markAllAsRead(for: device.id) { result in
            switch result {
            case .success:
                self.cachedEntities
                    .filter { !$0.opened && $0.visible }
                    .forEach { entity in
                        // Mark entity as read.
                        entity.opened = true

                        // No need to keep the item in the notification center.
                        self.removeItemFromNotificationCenter(entity.toModel())
                    }

                // Persist the changes to the database.
                self.database.saveChanges()

                // Notify the delegate.
                NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)

                // Refresh the badge if applicable.
                self.refreshBadge { _ in
                    completion(.success(()))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func remove(_ item: NotificareInboxItem, _ completion: @escaping NotificareInboxCallback<Void>) {
        guard let application = Notificare.shared.application,
              let api = Notificare.shared.pushApi
        else {
            NotificareLogger.warning("Notificare application not yet available.")
            completion(.failure(NotificareError.notReady))
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            completion(.failure(NotificareInboxError.inboxUnavailable))
            return
        }

        api.removeItem(item) { result in
            switch result {
            case .success:
                if let entity = self.cachedEntities.first(where: { $0.id == item.id }),
                   let index = self.cachedEntities.firstIndex(of: entity)
                {
                    self.database.remove(entity)
                    self.cachedEntities.remove(at: index)

                    self.removeItemFromNotificationCenter(item)
                }

                // Notify the delegate.
                NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)

                // Refresh the badge if applicable.
                self.refreshBadge { _ in
                    completion(.success(()))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func clear(_ completion: @escaping NotificareInboxCallback<Void>) {
        guard let application = Notificare.shared.application,
              let api = Notificare.shared.pushApi,
              let device = Notificare.shared.deviceManager.currentDevice
        else {
            NotificareLogger.warning("Notificare application not yet available.")
            completion(.failure(NotificareError.notReady))
            return
        }

        guard application.inboxConfig?.useInbox == true else {
            NotificareLogger.warning("Notificare inbox funcionality is not enabled.")
            completion(.failure(NotificareInboxError.inboxUnavailable))
            return
        }

        api.clearInbox(for: device.id) { result in
            switch result {
            case .success:
                self.clearLocalInbox()
                self.clearNotificationCenter()

                // Notify the delegate.
                NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)

                self.refreshBadge { _ in
                    completion(.success(()))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private API

    private func sync() {
        guard let api = Notificare.shared.pushApi,
              let device = Notificare.shared.deviceManager.currentDevice
        else {
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
        api.getInbox(for: device.id) { result in
            switch result {
            case .success:
                NotificareLogger.info("The inbox has been modified. Performing a full sync.")
                self.reloadInbox()

            case let .failure(error):
                if case let .networkFailure(cause) = error, case let .endpointError(response, _) = cause {
                    if response.statusCode == 304 {
                        NotificareLogger.debug("The inbox has not been modified. Proceeding with locally stored data.")
                        self.refreshBadge { _ in
                            NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)
                        }
                    }
                }
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
            fatalError("Failed to query the local database: \(error)")
        }
    }

    private func addToLocalInbox(_ item: NotificareInboxItem) {
        // NOTE: Remove duplicates for a given notification before adding the item to the inbox.
        // When receiving a triggered notification, we may receive it more than once.
        cachedEntities
            .filter { $0.notificationId == item.notificationId }
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
            NotificareLogger.error("Failed to clear the local inbox: \(error)")
        }
    }

    private func removeExpiredItemsFromNotificationCenter() {
        cachedEntities
            .map { $0.toModel() }
            .forEach { item in
                if item.expired {
                    removeItemFromNotificationCenter(item)
                }
            }
    }

    private func removeItemFromNotificationCenter(_ item: NotificareInboxItem) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            notifications.forEach { notification in
                if let id = notification.request.content.userInfo["id"] as? String, id == item.id {
                    NotificareLogger.debug("Removing inbox item '\(item.id)' from the notification center.")
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }
            }
        }
    }

    private func clearNotificationCenter() {
        NotificareLogger.debug("Removing all messages from the notification center.")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func requestRemoteInboxItems(step: Int = 0) {
        guard let api = Notificare.shared.pushApi,
              let device = Notificare.shared.deviceManager.currentDevice
        else {
            NotificareLogger.warning("Notificare has not been configured yet.")
            return
        }

        api.getInbox(for: device.id, skip: step * 100, limit: 100) { result in
            switch result {
            case let .success(response):
                // Add all items to the database.
                response.inboxItems.forEach { item in
                    self.addToLocalInbox(item)
                }

                if response.count > step * 100 {
                    NotificareLogger.debug("Loading more inbox items.")
                    self.requestRemoteInboxItems(step: step + 1)
                } else {
                    NotificareLogger.debug("Done loading inbox items.")

                    // Notify the delegate.
                    NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)

                    // Refresh the badge if applicable.
                    self.refreshBadge { _ in }
                }
            case let .failure(error):
                NotificareLogger.error("Failed to fetch inbox items.")
                NotificareLogger.debug("\(error)")
            }
        }
    }

    // MARK: - NotificationCenter events

    @objc private func onAddItemNotification(_ notification: Notification) {
        NotificareLogger.debug("Received a signal to add an item to the inbox.")

        guard let userInfo = notification.userInfo, let item = NotificareInboxItem(userInfo: userInfo) else {
            NotificareLogger.warning("Unable to parse inbox item.")
            return
        }

        addToLocalInbox(item)

        refreshBadge { _ in
            NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)
        }
    }

    @objc private func onReadItemNotification(_ notification: Notification) {
        NotificareLogger.debug("Received a signal to mark an item as read.")

        guard let userInfo = notification.userInfo, let notification = userInfo["notification"] as? NotificareNotification else {
            NotificareLogger.warning("Unable to handle the notification read request.")
            return
        }

        // Mark entities as read.
        cachedEntities
            .filter { $0.notificationId == notification.id }
            .forEach { $0.opened = true }

        // Persist the changes to the database.
        database.saveChanges()

        refreshBadge { _ in
            NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didUpdateInbox: self.visibleItems)
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

            guard let api = Notificare.shared.pushApi,
                  let device = Notificare.shared.deviceManager.currentDevice
            else {
                NotificareLogger.warning("Notificare has not been configured yet.")
                return
            }

            guard !self.cachedEntities.isEmpty else {
                NotificareLogger.debug("The inbox is empty. No need to do a full sync.")
                return
            }

            api.getInbox(for: device.id, skip: 0, limit: 1) { result in
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
