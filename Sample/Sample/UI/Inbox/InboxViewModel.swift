//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Combine
import Foundation
import NotificareInboxKit
import NotificareKit
import OSLog
import UIKit

class InboxViewModel: ObservableObject {
    @Published private(set) var sections: [InboxSection] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        let items = Notificare.shared.inbox().items
        sections = createSections(for: items)

        NotificationCenter.default
            .publisher(for: .inboxUpdated, object: nil)
            .sink { [weak self] notification in
                guard let self = self else { return }

                guard let items = notification.userInfo?["items"] as? [NotificareInboxItem] else {
                    Logger.main.error("Invalid notification payload.")
                    return
                }

                self.sections = self.createSections(for: items)
            }
            .store(in: &cancellables)
    }

    func getSectionHeader(_ section: InboxViewModel.InboxSection) -> String {
        switch section.group {
        case .today:
            return String(localized: "inbox_section_today")
        case .yesterday:
            return String(localized: "inbox_section_yesterday")
        case .lastSevenDays:
            return String(localized: "inbox_section_last_seven_days")
        case let .other(month, year):
            let monthName = DateFormatter().monthSymbols[month - 1]

            if year == Calendar.current.component(.year, from: Date()) {
                return monthName
            }

            return "\(monthName) \(year)"
        }
    }

    func presentInboxItem(_ item: NotificareInboxItem) {
        Logger.main.info("-----> Inbox item clicked <-----")
        Task {
            do {
                let notification = try await Notificare.shared.inbox().open(item)
                await UIApplication.shared.present(notification)
            } catch {
                Logger.main.error("Failed to open an inbox item. \(error.localizedDescription)")
            }
        }
    }

    func handleMarkItemAsRead(_ item: NotificareInboxItem) {
        Logger.main.info("-----> Mark as read clicked <-----")
        Task {
            do {
                try await Notificare.shared.inbox().markAsRead(item)
            } catch {
                Logger.main.error("Failed to mark an item as read. \(error.localizedDescription)")
            }
        }
    }

    func handleMarkAllItemsAsRead() {
        Logger.main.info("-----> Mark all as read clicked <-----")
        Task {
            do {
                try await Notificare.shared.inbox().markAllAsRead()
            } catch {
                Logger.main.error("Failed to mark all item as read. \(error.localizedDescription)")
            }
        }
    }

    func handleRemoveItem(_ item: NotificareInboxItem) {
        Logger.main.info("-----> Remove inbox item clicked <-----")
        Task {
            do {
                try await Notificare.shared.inbox().remove(item)
            } catch {
                Logger.main.error("Failed to remove an item. \(error.localizedDescription)")
            }
        }
    }

    func handleClearItems() {
        Logger.main.info("-----> Clear inbox clicked <-----")

        Task {
            do {
                try await Notificare.shared.inbox().clear()
            } catch {
                Logger.main.error("Failed to clear the inbox. \(error.localizedDescription)")
            }
        }
    }

    private func createSections(for items: [NotificareInboxItem]) -> [InboxSection] {
        var sections: [InboxSection] = []

        var filteredItems = items.filter { $0.time >= Date.today }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .today,
                    items: filteredItems
                )
            )
        }

        filteredItems = items.filter { $0.time >= Date.yesterday && $0.time < Date.today }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .yesterday,
                    items: filteredItems
                )
            )
        }

        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date.today)!

        filteredItems = items.filter { $0.time >= sevenDaysAgo && $0.time < Date.yesterday }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .lastSevenDays,
                    items: filteredItems
                )
            )
        }

        let remainingItems = Dictionary(
            grouping: items.filter { $0.time < sevenDaysAgo },
            by: { item in
                let month = Calendar.current.component(.month, from: item.time)
                let year = Calendar.current.component(.year, from: item.time)

                return InboxSection.Group.other(month: month, year: year)
            }
        ).map { key, value in
            InboxSection(
                group: key,
                items: value
            )
        }.sorted { lhs, rhs in
            if case let .other(lMonth, lYear) = lhs.group, case let .other(rMonth, rYear) = rhs.group {
                if lYear == rYear {
                    return lMonth > rMonth
                }

                return lYear > rYear
            }

            // should never happen.
            return false
        }

        sections.append(contentsOf: remainingItems)

        return sections
    }

    struct InboxSection: Identifiable {
        let group: Group
        let items: [NotificareInboxItem]

        var id: String {
            switch group {
            case .today:
                return "today"
            case .yesterday:
                return "yesterday"
            case .lastSevenDays:
                return "last_seven_days"
            case let .other(month, year):
                return "other_\(year)_\(month)"
            }
        }

        enum Group: Hashable {
            case today
            case yesterday
            case lastSevenDays
            case other(month: Int, year: Int)
        }
    }
}
