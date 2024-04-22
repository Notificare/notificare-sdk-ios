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
                    ListIconView(
                        icon: "arrow.up.message.fill",
                        foregroundColor: .white,
                        backgroundColor: Color(.systemIndigo)
                    )
                }
            }

            Toggle(isOn: $hasSuppressedOn) {
                Label {
                    Text(String(localized: "home_suppressed"))
                } icon: {
                    ListIconView(
                        icon: "stopwatch.fill",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
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
