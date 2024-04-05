//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog

@MainActor
internal class EventsViewModel: ObservableObject {
    @Published internal var eventFields = [EventField]()
    @Published internal var eventName = ""
    @Published internal private(set) var viewState: ViewState = .idle

    internal var isRegisterEventAllowed: Bool {
        !viewState.isLoading && !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    internal func addEventField() {
        let field = EventField(key: "", value: "")
        eventFields.append(field)
    }

    internal func registerEvent() {
        Logger.main.info("Register Event clicked")
        viewState = .loading
        let fields = validateEventFields()

        Task {
            do {
                try await Notificare.shared.events().logCustom(eventName, data: fields)

                Logger.main.info("Event \(self.eventName) registered successfully")
                eventName = ""
                eventFields = [EventField]()
                viewState = .success
            } catch {
                Logger.main.error("Failed to registered event \(self.eventName): \(error)")
                viewState = .failure(error: error)
            }
        }
    }

    private func validateEventFields() -> [String: String] {
        let fields = eventFields
            .filter { $0.key != "" && $0.value != "" }
            .map { ($0.key, $0.value) }

        return Dictionary(uniqueKeysWithValues: fields)
    }

    internal enum ViewState {
        case idle
        case loading
        case success
        case failure(error: Error)

        internal var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}

internal struct EventField: Identifiable {
    internal var id = UUID()
    internal var key: String
    internal var value: String
}
