//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareKit
import SwiftUI

struct DoNotDisturbSection: View {
    @Binding var hasDndEnabled: Bool
    @Binding var startTime: Date
    @Binding var endTime: Date

    let updateDndStatus: (Bool) -> Void
    let updateDndTime: () -> Void

    var body: some View {
        Section {
            Toggle(isOn: $hasDndEnabled) {
                Label {
                    Text(String(localized: "home_do_not_disturb"))
                } icon: {
                    Image(systemName: "moon.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color("system_indigo"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
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

struct DoNotDisturbSection_Previews: PreviewProvider {
    static var previews: some View {
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
