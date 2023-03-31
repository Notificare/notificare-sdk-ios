//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel: EventsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: EventsViewModel())
    }
    
    var body: some View {
        List {
            Section {
                TextField(String(localized: "event_name"), text: $viewModel.eventName)
                
                ForEach($viewModel.identifiableEventFields) { $field in
                    EventFieldView(field: $field)
                }
                
                Button(String(localized: "button_register")) {
                    viewModel.registerEvent()
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.eventName.isEmpty)
            } header: {
                HStack {
                    Text(String(localized: "event_register"))
                }
            }
        }
        .navigationTitle(String(localized: "events_title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                Button(action: viewModel.handleAddEventField) {
                    HStack(alignment: .top) {
                        Text(String(localized: "event_add_field"))
                    }
                }
        )
    }
}

private struct EventFieldView: View {
    @Binding var field: IdentifiableEventField
    
    var body: some View {
        HStack {
            TextField(String(localized: "event_key"), text: $field.key)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField(String(localized: "event_value"), text: $field.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
