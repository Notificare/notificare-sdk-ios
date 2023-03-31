//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct ChangePasswordSection: View {
    @StateObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Section {
            TextField(String(localized: "authentication_new_password"), text: $viewModel.changePasswordNewPassword)
            
            Button(String(localized: "authentication_change")) {
                viewModel.changePassword()
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.changePasswordNewPassword.isEmpty || viewModel.currentUser == nil)
        }
    }
}

struct ChangePasswordSection_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordSection(viewModel: AuthenticationViewModel())
    }
}
