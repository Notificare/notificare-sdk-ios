//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct DeviceRegistrationSection: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        Section {
            TextField(String(localized: "home_user_id"), text: $viewModel.userId)
                .disabled(viewModel.isDeviceRegistered)

            TextField(String(localized: "home_user_name"), text: $viewModel.userName)
                .disabled(viewModel.isDeviceRegistered)

            if viewModel.isDeviceRegistered {
                Button(String(localized: "button_clean_user")) {
                    viewModel.cleanDeviceRegistration()
                }
                .frame(maxWidth: .infinity)
            } else {
                Button(String(localized: "button_register_user")) {
                    viewModel.registerDevice()
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.userId.isEmpty)
            }
        } header: {
            Text(String(localized: "home_device_registration"))
        }
    }
}

struct DeviceRegistrationSection_Previews: PreviewProvider {
    static var previews: some View {
        DeviceRegistrationSection(viewModel: HomeViewModel())
    }
}
