//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct NotificationsSection: View {
    @Binding internal var hasNotificationsAndPermission: Bool

    internal let hasNotificationsEnabled: Bool
    internal let allowedUi: Bool
    internal let notificationsPermission: HomeViewModel.NotificationsPermissionStatus?
    internal let badge: Int
    internal let updateNotificationsStatus: (Bool) -> Void

    internal var body: some View {
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
                    HStack {
                        Text(String(localized: "home_inbox"))

                        Spacer(minLength: 16)

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
        } header: {
            Text(String(localized: "home_remote_notifications"))
        }
    }
}

internal struct NotificationsSection_Previews: PreviewProvider {
    internal static var previews: some View {
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
