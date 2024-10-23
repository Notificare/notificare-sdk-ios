//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import SwiftUI

internal struct AuthenticationSection: View {
    internal let isLoggedIn: Bool
    internal let isDeviceRegistered: Bool
    internal let startLoginFlow: () -> Void
    internal let startLogoutFlow: () -> Void

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_logged_in"))

                Spacer()

                Text(String(isLoggedIn))
            }

            HStack {
                Text(String(localized: "home_device_registered"))

                Spacer()

                Text(String(isDeviceRegistered))
            }

            HStack {
                Button(String(localized: "home_login")) {
                    startLoginFlow()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(isLoggedIn)

                Divider()

                Button(String(localized: "home_logout")) {
                    startLogoutFlow()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(!isLoggedIn)
            }
        } header: {
            Text(String(localized: "home_authentication_flow"))
        }
    }
}

internal struct AuthenticationSection_Previews: PreviewProvider {
    internal static var previews: some View {
        AuthenticationSection(
            isLoggedIn: false,
            isDeviceRegistered: false,
            startLoginFlow: {},
            startLogoutFlow: {}
        )
    }
}
