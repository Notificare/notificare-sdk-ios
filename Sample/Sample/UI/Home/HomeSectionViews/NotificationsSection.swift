//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct NotificationsSection: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        Section {
            Toggle(isOn: $viewModel.hasNotificationsAndPermission) {
                Label {
                    Text(String(localized: "home_notifications"))
                } icon: {
                    Image(systemName: "bell.badge.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .onChange(of: viewModel.hasNotificationsAndPermission) { enabled in
                viewModel.handleNotificationsToggle(enabled: enabled)
            }
            
            HStack {
                Text(String(localized: "home_enabled"))
                Text(String(localized: "sdk"))
                    .font(.caption2)
                Spacer()
                Text(String(viewModel.hasNotificationsEnabled))
            }
            
            HStack {
                Text(String(localized: "home_allowed_ui"))
                Text(String(localized: "sdk"))
                    .font(.caption2)
                Spacer()
                Text(String(viewModel.allowedUi))
            }
            
            HStack {
                Text(String(localized: "home_permission"))
                Spacer()
                Text(String(viewModel.notificationsPermission))
            }
            
            NavigationLink {
                InboxView()
            } label: {
                Label {
                    Text(String(localized: "home_inbox"))
                    
                    Spacer(minLength: 16)
                    
                    if viewModel.badge > 0 {
                        BadgeView(badge: viewModel.badge)
                    }
                } icon: {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            NavigationLink {
                TagsView(viewModel: TagsViewModel())
            } label: {
                Label {
                    Text(String(localized: "home_tags"))
                } icon: {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(6)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        } header: {
            Text(String(localized: "home_remote_notifications"))
        }
    }
}

struct NotificationsSection_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSection(viewModel: HomeViewModel())
    }
}
