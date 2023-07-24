//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct InAppMessagingSection: View {
    @Binding var hasEvaluateContextOn: Bool
    @Binding var hasSuppressedOn: Bool

    let updateSuppressedIamStatus: (Bool) -> Void

    var body: some View {
        Section {
            Toggle(isOn: $hasEvaluateContextOn) {
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

            Toggle(isOn: $hasSuppressedOn) {
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
            .onChange(of: hasSuppressedOn) { enabled in
                updateSuppressedIamStatus(enabled)
            }

        } header: {
            Text(String(localized: "home_in_app_messaging"))
        }
    }
}

struct InAppMessagingSection_Previews: PreviewProvider {
    static var previews: some View {
        @State var hasEvaluateContextOn = false
        @State var hasSuppressedOn = false
        InAppMessagingSection(
            hasEvaluateContextOn: $hasEvaluateContextOn,
            hasSuppressedOn: $hasSuppressedOn,
            updateSuppressedIamStatus: { _ in }
        )
    }
}
