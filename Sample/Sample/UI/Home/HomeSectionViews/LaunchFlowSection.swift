//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct LaunchFlowSection: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        Section {
            HStack {
                Text(String(localized: "home_configured"))
                Text(String(localized: "sdk"))
                    .font(.caption2)
                Spacer()
                Text(String(viewModel.isConfigured))
            }
            
            HStack {
                Text(String(localized: "home_ready"))
                Text(String(localized: "sdk"))
                    .font(.caption2)
                Spacer()
                Text(String(viewModel.isReady))
            }
            
            HStack {
                Button(String(localized: "home_launch")) {
                    viewModel.notificareLaunch()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(viewModel.isReady)
                
                Divider()
                
                Button(String(localized: "home_unlaunch")) {
                    viewModel.notificareUnlaunch()
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.isReady)
            }
        } header: {
            Text(String(localized: "home_launch_flow"))
        }
    }
}


struct LaunchFlowSection_Previews: PreviewProvider {
    static var previews: some View {
        LaunchFlowSection(viewModel: HomeViewModel())
    }
}
