//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import OSLog


class EventsViewModel: ObservableObject {
    @Published private var eventFields = NotificareEventData()
    @Published var identifiableEventFields = [IdentifiableEventField]()
    @Published var eventName = ""
    
    @MainActor
    func registerEvent() {
        updateEvenFields()
        
        Task {
            do {
                try await Notificare.shared.events().logCustom(eventName, data: eventFields)
                Logger.main.info("-----> Event \(self.eventName) registered successfully <-----")
                eventName = ""
                eventFields = NotificareEventData()
                identifiableEventFields = [IdentifiableEventField]()
            } catch {
                Logger.main.error("-----> Failed to registered event \(self.eventName): \(error.localizedDescription)")
            }
        }
    }
    
    private func updateEvenFields() {
        if !identifiableEventFields.isEmpty {
            identifiableEventFields.forEach { field in
                if field.key != "" && field.value != "" {
                    eventFields[field.key] = field.value
                }
            }
        }
    }
    
    func handleAddEventField() {
        Logger.main.info("-----> Add field clicked <-----")
        let field = IdentifiableEventField(key: "", value: "")
        identifiableEventFields.append(field)
    }
}

struct IdentifiableEventField: Identifiable {
    var id = UUID()
    var key: String
    var value: String
}
