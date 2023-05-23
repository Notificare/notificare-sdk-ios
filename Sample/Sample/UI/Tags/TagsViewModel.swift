//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog
import SwiftUI

private let DEFAULT_TAGS = ["Kotlin", "Java", "Swift"]

@MainActor
class TagsViewModel: ObservableObject {
    @Published var selectableTags = [SelectableTag]()
    @Published var input = ""
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var deviceTags: [String] = []
    @Published private(set) var userMessages: [UserMessage] = []

    init() {
        refresh()
    }

    func refresh() {
        Task {
            await refreshAsync()
        }
    }

    private func refreshAsync() async {
        viewState = .loading

        do {
            let tags = try await Notificare.shared.device().fetchTags()

            selectableTags = DEFAULT_TAGS
                .filter { !tags.contains($0) }
                .map { SelectableTag(tag: $0, isSelected: false) }

            deviceTags = tags
            viewState = .success

            userMessages.append(
                UserMessage(variant: .fetchTagsSuccess)
            )
        } catch {
            Logger.main.error("Failed to fetch device tags: \(error)")
            viewState = .failure

            userMessages.append(
                UserMessage(variant: .fetchTagsFailure(error: error))
            )
        }
    }

    func saveChanges() {
        viewState = .loading

        var tags = selectableTags
            .filter(\.isSelected)
            .map(\.tag)

        let input = input.replacingOccurrences(of: " ", with: "_")
            .trimmingCharacters(in: .newlines)

        if !input.isEmpty, !tags.contains(input) {
            tags.append(input)
        }

        Task {
            do {
                try await Notificare.shared.device().addTags(tags)

                self.input = ""
                await refreshAsync()

                userMessages.append(
                    UserMessage(variant: .addTagsSuccess)
                )
            } catch {
                Logger.main.error("Failed to add tags: \(error)")

                userMessages.append(
                    UserMessage(variant: .addTagsFailure(error: error))
                )
            }
        }
    }

    func removeTag(_ tag: String) {
        viewState = .loading

        Task {
            do {
                try await Notificare.shared.device().removeTag(tag)

                await refreshAsync()

                userMessages.append(
                    UserMessage(variant: .removeTagSuccess)
                )
            } catch {
                Logger.main.error("Failed to remove tag '\(tag)': \(error)")

                userMessages.append(
                    UserMessage(variant: .removeTagFailure(error: error))
                )
            }
        }
    }

    func clearTags() {
        viewState = .loading

        Task {
            do {
                try await Notificare.shared.device().clearTags()

                await refreshAsync()

                userMessages.append(
                    UserMessage(variant: .clearTagsSuccess)
                )
            } catch {
                Logger.main.error("Failed to clear tags: \(error)")

                userMessages.append(
                    UserMessage(variant: .clearTagsFailure(error: error))
                )
            }
        }
    }

    func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    enum ViewState {
        case idle
        case loading
        case success
        case failure
    }

    struct UserMessage {
        let uniqueId = UUID().uuidString
        let variant: Variant

        enum Variant {
            case fetchTagsSuccess
            case fetchTagsFailure(error: Error)
            case addTagsSuccess
            case addTagsFailure(error: Error)
            case removeTagSuccess
            case removeTagFailure(error: Error)
            case clearTagsSuccess
            case clearTagsFailure(error: Error)
        }
    }
}

struct SelectableTag: Identifiable {
    let id = UUID()
    var tag: String
    var isSelected: Bool
}
