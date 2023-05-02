//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct UserPreferencesSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        Section {
            if viewModel.currentUser == nil {
                Label(String(localized: "authentication_not_available_please_login"), systemImage: "info.circle.fill")
            } else {
                Picker(String(localized: "authentication_choose_the_preferece"), selection: $viewModel.selectedPreferenceId) {
                    ForEach(viewModel.fetchedPreferences) { preference in
                        Text(preference.label).tag(preference.id)
                    }
                }
                .onChange(of: viewModel.selectedPreferenceId) { _ in
                    viewModel.updatePreferenceOptions()
                }

                Picker(String(localized: "authentication_choose_the_option"), selection: $viewModel.selectedOptionIndex) {
                    ForEach(0 ..< viewModel.preferenceOptions.count, id: \.self) { index in
                        Text(viewModel.preferenceOptions[index].label).tag(index)
                    }
                }

                HStack {
                    Button(String(localized: "button_add")) {
                        viewModel.addUserSegmentToPreference()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.fetchedPreferences.isEmpty)

                    Divider()

                    Button(String(localized: "button_remove")) {
                        viewModel.removeUserSegmentFromPreference()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.fetchedPreferences.isEmpty)
                }
            }
        } header: {
            Text(String(localized: "authentication_user_preferences"))
        }
    }
}

struct UserPreferencesSection_Previews: PreviewProvider {
    static var previews: some View {
        UserPreferencesSection(viewModel: AuthenticationViewModel())
    }
}
