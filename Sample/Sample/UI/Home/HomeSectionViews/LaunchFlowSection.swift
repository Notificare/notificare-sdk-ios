//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct LaunchFlowSection: View {
    let isReady: Bool
    let isConfigured: Bool
    let launch: () -> Void
    let unlaunch: () -> Void

    var body: some View {
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

struct LaunchFlowSection_Previews: PreviewProvider {
    static var previews: some View {
        LaunchFlowSection(isReady: false, isConfigured: false, launch: {}, unlaunch: {})
    }
}
