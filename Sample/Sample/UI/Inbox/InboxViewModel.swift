//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Combine
import Foundation
import NotificareInboxKit
import NotificareKit
import OSLog
import UIKit

@MainActor
internal class InboxViewModel: ObservableObject {
    @Published internal private(set) var items: [NotificareInboxItem] = []
    @Published internal private(set) var userMessages: [UserMessage] = []

    private var cancellables = Set<AnyCancellable>()

    internal init() {
        let items = Notificare.shared.inbox().items
        self.items = items

        NotificationCenter.default
            .publisher(for: .inboxUpdated, object: nil)
            .sink { [weak self] notification in
                guard let self = self else { return }

                guard let items = notification.userInfo?["items"] as? [NotificareInboxItem] else {
                    Logger.main.error("Invalid notification payload.")
                    return
                }

                self.items = items
            }
            .store(in: &cancellables)
    }

    internal func presentInboxItem(_ item: NotificareInboxItem) {
        Logger.main.info("Inbox item clicked")

        Task {
            do {
                let notification = try await Notificare.shared.inbox().open(item)
                UIApplication.shared.present(notification)

                userMessages.append(
                    UserMessage(variant: .presentItemSuccess)
                )
            } catch {
                Logger.main.error("Failed to open an inbox item. \(error)")

                userMessages.append(
                    UserMessage(variant: .presentItemFailure)
                )
            }
        }
    }

    internal func markItemAsRead(_ item: NotificareInboxItem) {
        Logger.main.info("Mark as read clicked")

        Task {
            do {
                try await Notificare.shared.inbox().markAsRead(item)

                userMessages.append(
                    UserMessage(variant: .markItemAsReadSuccess)
                )
            } catch {
                Logger.main.error("Failed to mark an item as read. \(error)")

                userMessages.append(
                    UserMessage(variant: .markItemAsReadFailure)
                )
            }
        }
    }

    internal func markAllItemsAsRead() {
        Logger.main.info("Mark all as read clicked")

        Task {
            do {
                try await Notificare.shared.inbox().markAllAsRead()

                userMessages.append(
                    UserMessage(variant: .markAllItemsAsReadSuccess)
                )
            } catch {
                Logger.main.error("Failed to mark all item as read. \(error)")

                userMessages.append(
                    UserMessage(variant: .markAllItemsAsReadFailure)
                )
            }
        }
    }

    internal func removeItem(_ item: NotificareInboxItem) {
        Logger.main.info("Remove inbox item clicked")

        Task {
            do {
                try await Notificare.shared.inbox().remove(item)

                userMessages.append(
                    UserMessage(variant: .removeItemSuccess)
                )
            } catch {
                Logger.main.error("Failed to remove an item. \(error)")

                userMessages.append(
                    UserMessage(variant: .removeItemFailure)
                )
            }
        }
    }

    internal func clearItems() {
        Logger.main.info("Clear inbox clicked")

        Task {
            do {
                try await Notificare.shared.inbox().clear()

                userMessages.append(
                    UserMessage(variant: .clearItemsSuccess)
                )
            } catch {
                Logger.main.error("Failed to clear the inbox. \(error)")

                userMessages.append(
                    UserMessage(variant: .clearItemsFailure)
                )
            }
        }
    }

    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant: Equatable {
            case presentItemSuccess
            case presentItemFailure
            case markItemAsReadSuccess
            case markItemAsReadFailure
            case markAllItemsAsReadSuccess
            case markAllItemsAsReadFailure
            case removeItemSuccess
            case removeItemFailure
            case clearItemsSuccess
            case clearItemsFailure
        }
    }
}
