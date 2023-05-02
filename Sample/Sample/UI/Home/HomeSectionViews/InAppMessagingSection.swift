//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct InAppMessagingSection: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasEvaluateContextOn) {
                Label {
                    Text(String(localized: "home_evaluate_context"))
                } icon: {
                    Image(systemName: "arrow.up.message.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color("system_indigo"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            Toggle(isOn: $viewModel.hasSuppressedOn) {
                Label {
                    Text(String(localized: "home_suppressed"))
                } icon: {
                    Image(systemName: "stopwatch.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .onChange(of: viewModel.hasSuppressedOn) { enabled in
                viewModel.handleSuppressedToggle(enabled: enabled)
            }

        } header: {
            Text(String(localized: "home_in_app_messaging"))
        }
    }
}

struct InAppMessagingSection_Previews: PreviewProvider {
    static var previews: some View {
        InAppMessagingSection(viewModel: HomeViewModel())
    }
}
