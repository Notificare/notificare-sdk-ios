import Foundation
import NotificareKit

internal actor InboxCache {
    internal private(set) var items: [LocalInboxItem] = []

    internal func set(_ items: [LocalInboxItem]) {
        self.items = items
    }

    internal func add(_ item: LocalInboxItem) {
        items.insertSorted(item, by: { $0.time > $1.time})
    }

    internal func update(_ item: NotificareInboxItem, _ block: (inout LocalInboxItem) -> Void) -> LocalInboxItem? {
        return update(item.id, block)
    }

    internal func update(_ item: LocalInboxItem, _ block: (inout LocalInboxItem) -> Void) -> LocalInboxItem? {
        return update(item.id, block)
    }

    internal func update(_ id: String, _ block: (inout LocalInboxItem) -> Void) -> LocalInboxItem? {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        var localItem = items[index]
        block(&localItem)
        items[index] = localItem

        return localItem
    }

    internal func removeAll(id: String) {
        items.removeAll(where: { $0.id == id })
    }

    internal func removeAll(notificationId: String) {
        items.removeAll(where: { $0.notification.id == notificationId })
    }

    internal func removeAll() {
        items.removeAll()
    }
}
