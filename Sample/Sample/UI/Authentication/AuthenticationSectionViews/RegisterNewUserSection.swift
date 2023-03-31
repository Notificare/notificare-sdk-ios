//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct RegisterNewUserSection: View {
    @StateObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Section {
            TextField(String(localized: "authentication_email"), text: $viewModel.newUserEmail)
            TextField(String(localized: "authentication_password"), text: $viewModel.newUserPassword)
            TextField(String(localized: "authentication_user_name"), text: $viewModel.newUserName)
            
            
            Button(String(localized: "authentication_register_new_account")) {
                viewModel.registerNewUser()
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.newUserEmail.isEmpty || viewModel.newUserPassword.isEmpty || viewModel.newUserName.isEmpty || viewModel.currentUser != nil)
        } header: {
            Text(String(localized: "authentication_register_new_account"))
        }
    }
}

struct RegisterNewUserSection_Previews: PreviewProvider {
    static var previews: some View {
        RegisterNewUserSection(viewModel: AuthenticationViewModel())
    }
}
