//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct AccountAuthenticationSection: View {
    @StateObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Section {
            TextField(String(localized: "authentication_email"), text: $viewModel.loginEmail)
            TextField(String(localized: "authentication_password"), text: $viewModel.loginPassword)
            
            VStack {
                HStack {
                    Button(String(localized: "authentication_login")) {
                        viewModel.login()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.loginEmail.isEmpty || viewModel.loginPassword.isEmpty || viewModel.currentUser != nil)
                    
                    Divider()
                    
                    Button(String(localized: "authentication_logout")) {
                        viewModel.logout()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.currentUser == nil)
                }
            }
        } header: {
            Text(String(localized: "authentication_account"))
        }
    }
}

struct AccountAuthenticationSection_Previews: PreviewProvider {
    static var previews: some View {
        AccountAuthenticationSection(viewModel: AuthenticationViewModel())
    }
}
