//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        List {
            Section {
                TextField(String(localized: "event_name"), text: $viewModel.eventName)
                    .disabled(viewModel.viewState.isLoading)

                if !viewModel.viewState.isLoading {
                    ForEach($viewModel.eventFields) { $field in
                        EventFieldView(field: $field)
                    }
                }

                Button(String(localized: "button_register")) {
                    viewModel.registerEvent()
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isRegisterEventAllowed)
            } header: {
                HStack {
                    Text(String(localized: "event_register"))
                }
            }

            ZStack {
                switch viewModel.viewState {
                case .idle:
                    EmptyView()

                case .loading:
                    ProgressView()

                case .success:
                    Label {
                        Text(String(localized: "event_registered"))
                    } icon: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }

                case .failure:
                    Label {
                        Text(String(localized: "error_message_events_register"))
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(String(localized: "events_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(String(localized: "event_add_field")) {
                    viewModel.addEventField()
                }
            }
        }
    }
}

private struct EventFieldView: View {
    @Binding var field: EventField

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
