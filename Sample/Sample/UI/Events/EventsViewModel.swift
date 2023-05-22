//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog

@MainActor
class EventsViewModel: ObservableObject {
    @Published var eventFields = [EventField]()
    @Published var eventName = ""
    @Published private(set) var viewState: ViewState = .idle

    var isRegisterEventAllowed: Bool {
        !viewState.isLoading && !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addEventField() {
        let field = EventField(key: "", value: "")
        eventFields.append(field)
    }
    
    func registerEvent() {
        Logger.main.info("-----> Register Event clicked <-----")
        viewState = .loading
        let fields = validateEvenFields()
        
        Task {
            do {
                try await Notificare.shared.events().logCustom(eventName, data: fields)
                Logger.main.info("-----> Event \(self.eventName) registered successfully <-----")
                eventName = ""
                eventFields = [EventField]()
                viewState = .success
            } catch {
                Logger.main.error("-----> Failed to registered event \(self.eventName): \(error.localizedDescription)")
                viewState = .failure(error: error)
            }
        }
    }

    private func validateEvenFields() -> [String: String] {
        let fields = eventFields
            .filter { $0.key != "" && $0.value != ""}
            .map { ($0.key, $0.value) }

        return Dictionary(uniqueKeysWithValues: fields)
    }

    enum ViewState {
        case idle
        case loading
        case success
        case failure(error: Error)

        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}

struct EventField: Identifiable {
    var id = UUID()
    var key: String
    var value: String
}
