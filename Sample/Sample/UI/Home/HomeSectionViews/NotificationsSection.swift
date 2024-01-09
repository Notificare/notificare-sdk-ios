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
                    ListIconView(
                        icon: "bell.badge.fill",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
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
                    ListIconView(
                        icon: "tray.and.arrow.down.fill",
                        foregroundColor: .white,
                        backgroundColor: .blue
                    )
                }
            }

            NavigationLink {
                TagsView()
            } label: {
                Label {
                    Text(String(localized: "home_tags"))
                } icon: {
                    ListIconView(
                        icon: "tag.fill",
                        foregroundColor: .white,
                        backgroundColor: .orange
                    )
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
