//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct DeviceRegistrationSection: View {
    @Binding var userId: String
    @Binding var userName: String

    let isDeviceRegistered: Bool
    let cleanDeviceRegistration: () -> Void
    let registerDevice: () -> Void

    var body: some View {
        Section {
            TextField(String(localized: "home_user_id"), text: $userId)
                .disabled(isDeviceRegistered)

            TextField(String(localized: "home_user_name"), text: $userName)
                .disabled(isDeviceRegistered)

            if isDeviceRegistered {
                Button(String(localized: "button_clean_user")) {
                    cleanDeviceRegistration()
                }
                .frame(maxWidth: .infinity)
            } else {
                Button(String(localized: "button_register_user")) {
                    registerDevice()
                }
                .frame(maxWidth: .infinity)
                .disabled(userId.isEmpty)
            }
        } header: {
            Text(String(localized: "home_device_registration"))
        }
    }
}

struct DeviceRegistrationSection_Previews: PreviewProvider {
    static var previews: some View {
        @State var userId = ""
        @State var userName = ""
        DeviceRegistrationSection(userId: $userId, userName: $userName, isDeviceRegistered: false, cleanDeviceRegistration: {}, registerDevice: {})
    }
}
