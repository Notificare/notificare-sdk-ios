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
class InboxViewModel: ObservableObject {
    @Published private(set) var items: [NotificareInboxItem] = []
    @Published private(set) var userMessages: [UserMessage] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
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

    func presentInboxItem(_ item: NotificareInboxItem) {
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
                    UserMessage(variant: .presentItemFailure(error: error))
                )
            }
        }
    }

    func markItemAsRead(_ item: NotificareInboxItem) {
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
                    UserMessage(variant: .markItemAsReadFailure(error: error))
                )
            }
        }
    }

    func markAllItemsAsRead() {
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
                    UserMessage(variant: .markAllItemsAsReadFailure(error: error))
                )
            }
        }
    }

    func removeItem(_ item: NotificareInboxItem) {
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
                    UserMessage(variant: .removeItemFailure(error: error))
                )
            }
        }
    }

    func clearItems() {
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
                    UserMessage(variant: .clearItemsFailure(error: error))
                )
            }
        }
    }

    func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    struct UserMessage: Equatable {
        static func == (lhs: UserMessage, rhs: UserMessage) -> Bool {
            lhs.uniqueId == rhs.uniqueId && lhs.variant == rhs.variant
        }

        let uniqueId = UUID().uuidString
        let variant: Variant

        enum Variant: Equatable {
            case presentItemSuccess
            case presentItemFailure(error: Error)
            case markItemAsReadSuccess
            case markItemAsReadFailure(error: Error)
            case markAllItemsAsReadSuccess
            case markAllItemsAsReadFailure(error: Error)
            case removeItemSuccess
            case removeItemFailure(error: Error)
            case clearItemsSuccess
            case clearItemsFailure(error: Error)

            static func == (lhs: Variant, rhs: Variant) -> Bool {
                switch (lhs, rhs) {
                case (.presentItemSuccess, .presentItemSuccess),
                     (.markItemAsReadSuccess, .markItemAsReadSuccess),
                     (.markAllItemsAsReadSuccess, .markAllItemsAsReadSuccess),
                     (.removeItemSuccess, .removeItemSuccess),
                     (.clearItemsSuccess, .clearItemsSuccess):
                    return true

                case let (.presentItemFailure(lhsError), .presentItemFailure(rhsError)),
                     let (.markItemAsReadFailure(lhsError), .markItemAsReadFailure(rhsError)),
                     let (.markAllItemsAsReadFailure(lhsError), .markAllItemsAsReadFailure(rhsError)),
                     let (.removeItemFailure(lhsError), .removeItemFailure(rhsError)),
                     let (.clearItemsFailure(lhsError), .clearItemsFailure(rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription

                default:
                    return false
                }
            }
        }
    }
}
