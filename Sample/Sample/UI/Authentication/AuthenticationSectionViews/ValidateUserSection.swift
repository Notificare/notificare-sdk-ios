//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct ValidateUserSection: View {
    @StateObject var viewModel: AuthenticationViewModel

    var body: some View {
        Section {
            TextField(String(localized: "authentication_token"), text: $viewModel.validateUserToken)

            Button(String(localized: "authentication_validate")) {
                viewModel.validateUser()
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.validateUserToken.isEmpty)
        } header: {
            Text(String(localized: "authentication_validate_user"))
        }
    }
}

struct ValidateUserSection_Previews: PreviewProvider {
    static var previews: some View {
        ValidateUserSection(viewModel: AuthenticationViewModel())
    }
}
