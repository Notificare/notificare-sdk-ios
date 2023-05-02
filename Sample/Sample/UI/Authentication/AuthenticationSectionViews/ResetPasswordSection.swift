//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct ResetPasswordSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        Section {
            TextField(String(localized: "authentication_password"), text: $viewModel.resetPasswordNewPassword)
            TextField(String(localized: "authentication_token"), text: $viewModel.resetPasswordToken)

            Button(String(localized: "authentication_reset")) {
                viewModel.resetPassword()
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.resetPasswordNewPassword.isEmpty || viewModel.resetPasswordToken.isEmpty || viewModel.currentUser != nil)
        }
    }
}

struct ResetPasswordSection_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordSection(viewModel: AuthenticationViewModel())
    }
}
