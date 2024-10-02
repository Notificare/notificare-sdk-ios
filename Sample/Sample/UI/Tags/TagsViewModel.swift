//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog
import SwiftUI

private let DEFAULT_TAGS = ["Kotlin", "Java", "Swift"]

@MainActor
internal class TagsViewModel: ObservableObject {
    @Published internal var selectableTags = [SelectableTag]()
    @Published internal var input = ""
    @Published internal private(set) var viewState: ViewState = .idle
    @Published internal private(set) var deviceTags: [String] = []
    @Published internal private(set) var userMessages: [UserMessage] = []

    internal init() {
        refresh()
    }

    internal func refresh() {
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

            userMessages.append(
                UserMessage(variant: .fetchTagsFailure)
            )

            viewState = .failure
        }
    }

    internal func saveChanges() {
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
                    UserMessage(variant: .addTagsFailure)
                )

                viewState = .failure
            }
        }
    }

    internal func removeTag(_ tag: String) {
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
                    UserMessage(variant: .removeTagFailure)
                )

                viewState = .failure
            }
        }
    }

    internal func clearTags() {
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
                    UserMessage(variant: .clearTagsFailure)
                )

                viewState = .failure
            }
        }
    }

    internal func processUserMessage(_ userMessageId: String) {
        userMessages.removeAll(where: { $0.uniqueId == userMessageId })
    }

    internal enum ViewState {
        case idle
        case loading
        case success
        case failure
    }

    internal struct UserMessage: Equatable {
        internal let uniqueId = UUID().uuidString
        internal let variant: Variant

        internal enum Variant: Equatable {
            case fetchTagsSuccess
            case fetchTagsFailure
            case addTagsSuccess
            case addTagsFailure
            case removeTagSuccess
            case removeTagFailure
            case clearTagsSuccess
            case clearTagsFailure
        }
    }
}

internal struct SelectableTag: Identifiable {
    internal let id = UUID()
    internal var tag: String
    internal var isSelected: Bool
}
