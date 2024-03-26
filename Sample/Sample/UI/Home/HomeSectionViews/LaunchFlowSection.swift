//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct LaunchFlowSection: View {
    internal let isReady: Bool
    internal let isConfigured: Bool
    internal let launch: () -> Void
    internal let unlaunch: () -> Void

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_configured"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(isConfigured))
            }

            HStack {
                Text(String(localized: "home_ready"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(isReady))
            }

            HStack {
                Button(String(localized: "home_unlaunch")) {
                    unlaunch()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(!isReady)

                Divider()

                Button(String(localized: "home_launch")) {
                    launch()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(isReady)
            }
        } header: {
            Text(String(localized: "home_launch_flow"))
        }
    }
}

internal struct LaunchFlowSection_Previews: PreviewProvider {
    internal static var previews: some View {
        LaunchFlowSection(
            isReady: false,
            isConfigured: false,
            launch: {},
            unlaunch: {}
        )
    }
}
