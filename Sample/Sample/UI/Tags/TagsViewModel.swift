//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog
import SwiftUI

@MainActor
class TagsViewModel: ObservableObject {
    @Published private(set) var deviceTags = [String]()
    @Published private(set) var selectedTags = [String]()
    @Published var availableTags = [AvailableTag]()
    @Published var inputTag = ""

    private let defaultTags = ["Kotlin", "Java", "Swift"]

    init() {
        getDeviceTags()
    }

    func getDeviceTags() {
        Logger.main.info("-----> Fetching device tags <-----")

        Task {
            do {
                let tags = try await Notificare.shared.device().fetchTags()
                Logger.main.info("-----> Device tags fetched successfully <-----")
                deviceTags = tags
            } catch {
                Logger.main.error("-----> Failed to fetch device tags: \(error.localizedDescription)")
                deviceTags.removeAll()
            }

            if !availableTags.isEmpty {
                availableTags.removeAll()
            }

            defaultTags.forEach { tag in
                if !deviceTags.contains(tag) {
                    availableTags.append(AvailableTag(name: tag, isSelected: false))
                }
            }
        }
    }

    func addTags() {
        Logger.main.info("-----> Add tags clicked <-----")
        if !inputTag.isEmpty {
            selectedTags.append(inputTag)
        }

        Task {
            do {
                try await Notificare.shared.device().addTags(selectedTags)

                Logger.main.info("-----> Added tags successfully <-----")
                inputTag = ""
                selectedTags.removeAll()
                getDeviceTags()
            } catch {
                Logger.main.error("-----> Failed to add tags: \(error.localizedDescription)")
            }
        }
    }

    func removeTag(tag: String) {
        Logger.main.info("-----> Remove Tag Clicked <-----")

        Task {
            do {
                try await Notificare.shared.device().removeTag(tag)

                Logger.main.info("-----> Tag removed Successfully <-----")
                getDeviceTags()
            } catch {
                Logger.main.error("-----> Failed to remove Tag '\(tag): \(error.localizedDescription)")
            }
        }
    }

    func clearTags() {
        Logger.main.info("-----> Clear tags Clicked <-----")

        Task {
            do {
                try await Notificare.shared.device().clearTags()

                Logger.main.info("-----> Tags cleared Successfully <-----")
                getDeviceTags()
            } catch {
                Logger.main.error("-----> Failed to Clear Tags Successfully: \(error.localizedDescription)")
            }
        }
    }

    func handleSelectedTag(tag: String) {
        if selectedTags.contains(tag) {
            Logger.main.info("-----> Tag \(tag) Unselected <-----")
            selectedTags.removeAll { $0 == tag }
        } else {
            Logger.main.info("-----> Tag \(tag) Selected <-----")
            selectedTags.append(tag)
        }
    }
}

struct AvailableTag: Identifiable {
    var id = UUID()
    var name: String
    var isSelected: Bool
}
