//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct SendPasswordResetSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        Section {
            TextField(String(localized: "authentication_email"), text: $viewModel.sendPasswordResetEmail)

            Button(String(localized: "authentication_send_password_reset")) {
                viewModel.sendPasswordReset()
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.sendPasswordResetEmail.isEmpty || viewModel.currentUser != nil)
        } header: {
            Text(String(localized: "authentication_password"))
        }
    }
}

struct SendPasswordResetSection_Previews: PreviewProvider {
    static var previews: some View {
        SendPasswordResetSection(viewModel: AuthenticationViewModel())
    }
}
