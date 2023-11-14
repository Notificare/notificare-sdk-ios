//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct NotificationsSection: View {
    @Binding var hasNotificationsAndPermission: Bool

    let hasNotificationsEnabled: Bool
    let allowedUi: Bool
    let notificationsPermission: HomeViewModel.NotificationsPermissionStatus?
    let badge: Int
    let updateNotificationsStatus: (Bool) -> Void

    var body: some View {
        Section {
            Toggle(isOn: $hasNotificationsAndPermission) {
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
            .onChange(of: hasNotificationsAndPermission) { enabled in
                updateNotificationsStatus(enabled)
            }

            HStack {
                Text(String(localized: "home_enabled"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(hasNotificationsEnabled))
            }

            HStack {
                Text(String(localized: "home_allowed_ui"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(String(allowedUi))
            }

            HStack {
                Text(String(localized: "home_permission"))

                Spacer()

                Text(String(notificationsPermission?.localized ?? ""))
            }

            NavigationLink {
                InboxView()
            } label: {
                Label {
                    Text(String(localized: "home_inbox"))

                    Spacer(minLength: 16)

                    if badge > 0 {
                        BadgeView(badge: badge)
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
                TagsView()
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
        @State var hasNotificationsAndPermission = false
        NotificationsSection(
            hasNotificationsAndPermission: $hasNotificationsAndPermission,
            hasNotificationsEnabled: false, allowedUi: false,
            notificationsPermission: HomeViewModel.NotificationsPermissionStatus.granted,
            badge: 2,
            updateNotificationsStatus: { _ in }
        )
    }
}
