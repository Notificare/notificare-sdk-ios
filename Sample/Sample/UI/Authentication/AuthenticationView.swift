//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    
    
    
    init() {
        self._viewModel = StateObject(wrappedValue: AuthenticationViewModel())
    }
    
    var body: some View {
        List {
            CurrentUserSection(viewModel: viewModel)
            RegisterNewUserSection(viewModel: viewModel)
            ValidateUserSection(viewModel: viewModel)
            AccountAuthenticationSection(viewModel: viewModel)
            SendPasswordResetSection(viewModel: viewModel)
            ResetPasswordSection(viewModel: viewModel)
            ChangePasswordSection(viewModel: viewModel)
            FetchedSegmentsSection(viewModel: viewModel)
            UserSegmentsSection(viewModel: viewModel)
            UserPreferencesSection(viewModel: viewModel)
        }
        .navigationTitle(String(localized: "authentication_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
