//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel: HomeViewModel

    @State private var isActive = false

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        List {
            LaunchFlowSection(viewModel: viewModel)
            NotificationsSection(viewModel: viewModel)
            DoNotDisturbSection(viewModel: viewModel)

            if #available(iOS 16.1, *), LiveActivitiesController.shared.hasLiveActivityCapabilities {
                LiveActivitiesSection(viewModel: viewModel)
            }

            LocationSection(viewModel: viewModel)
            InAppMessagingSection(viewModel: viewModel)
            DeviceRegistrationSection(viewModel: viewModel)
            OtherFeaturesSection()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if !isActive {
                    isActive = true

                    return
                }

                if !viewModel.hasNotificationsEnabled {
                    viewModel.checkNotificationsStatus()
                }
            }
        }
        .onOpenURL { url in
            viewModel.handleUrl(url: url)
        }
        .navigationTitle(String(localized: "home_title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
            Button(action: {
                viewModel.handleUpdateStats()
            }, label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            })
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
