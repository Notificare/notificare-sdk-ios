//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificareKit

public class NotificareInbox: NSObject, NotificareModule {
    public static let shared = NotificareInbox()

    public weak var delegate: NotificareInboxDelegate?

    public static func configure(applicationKey _: String, applicationSecret _: String) {
        // Listen to inbox addition requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(add(notification:)),
                                               name: NotificareDefinitions.InternalNotification.addInboxItem,
                                               object: nil)

        // Listen to badge refresh requests.
        NotificationCenter.default.addObserver(NotificareInbox.shared,
                                               selector: #selector(refreshBadge(notification:)),
                                               name: NotificareDefinitions.InternalNotification.refreshBadge,
                                               object: nil)
    }

    public static func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func reloadInbox() {}

    // func updateInboxItem(_ item: NotificareInboxItem)

    public func refresh() {
        //
    }

    public func refreshBadge(_ completion: NotificareCallback<Int>) {
        _ = completion
    }

    public func fetch(_ completion: NotificareCallback<[NotificareInboxItem]>) {
        _ = completion
    }

    public func add(_ item: NotificareInboxItem) {
        print(item)

        // TODO: add to local inbox

        refreshBadge { _ in
            // TODO: NotificareInbox.shared.delegate?.notificare(NotificareInbox.shared, didLoadInbox: cachedItems)
        }
    }

    public func remove(_ item: NotificareInboxItem) {
        _ = item
    }

    public func clear() {
        //
    }

    public func read(_ item: NotificareInboxItem) {
        _ = item
    }

    public func readAll() {
        //
    }

    @objc private func add(notification: Notification) {
        NotificareLogger.debug("Received a signal to add an item to the inbox.")

        guard let userInfo = notification.userInfo, let item = NotificareInboxItem(userInfo: userInfo) else {
            NotificareLogger.warning("Unable to parse inbox item.")
            return
        }

        add(item)
    }

    @objc private func refreshBadge(notification _: Notification) {
        NotificareLogger.debug("Received a signal to refresh the badge.")
    }
}
