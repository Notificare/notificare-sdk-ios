//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareKit
import SwiftUI

internal struct DoNotDisturbSection: View {
    @Binding internal var hasDndEnabled: Bool
    @Binding internal var startTime: Date
    @Binding internal var endTime: Date

    internal let updateDndStatus: (Bool) -> Void
    internal let updateDndTime: () -> Void

    internal var body: some View {
        Section {
            Toggle(isOn: $hasDndEnabled) {
                Label {
                    Text(String(localized: "home_do_not_disturb"))
                } icon: {
                    ListIconView(
                        icon: "moon.fill",
                        foregroundColor: .white,
                        backgroundColor: Color("system_indigo")
                    )
                }
            }
            .onChange(of: hasDndEnabled) { enabled in
                updateDndStatus(enabled)
            }

            if hasDndEnabled {
                DatePicker(
                    String(localized: "home_do_not_disturb_start"),
                    selection: $startTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: startTime) { _ in
                    updateDndTime()
                }

                DatePicker(
                    String(localized: "home_do_not_disturb_end"),
                    selection: $endTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: endTime) { _ in
                    updateDndTime()
                }
            }
        }
    }
}

internal struct DoNotDisturbSection_Previews: PreviewProvider {
    internal static var previews: some View {
        @State var hasDndEnabled = false
        @State var startTime = NotificareTime.defaultStart.date
        @State var endTime = NotificareTime.defaultEnd.date
        DoNotDisturbSection(
            hasDndEnabled: $hasDndEnabled,
            startTime: $startTime,
            endTime: $endTime,
            updateDndStatus: { _ in },
            updateDndTime: {}
        )
    }
}
