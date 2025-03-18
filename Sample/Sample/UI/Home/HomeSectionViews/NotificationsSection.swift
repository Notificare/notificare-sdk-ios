//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct NotificationsSection: View {
    @Binding internal var hasNotificationsAndPermission: Bool

    internal let hasNotificationsEnabled: Bool
    internal let allowedUi: Bool
    internal let subscriptionToken: String?
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
                Text(String(localized: "home_subscription_token"))

                Text(String(localized: "sdk"))
                    .font(.caption2)

                Spacer()

                Text(subscriptionToken.map { "...\($0.suffix(16))" } ?? "")
            }

            HStack {
                Text(String(localized: "home_permission"))

                Spacer()

                Text(String(notificationsPermission?.localized ?? ""))
            }

            NavigationLink {
                InboxView()
            } label: {
                HStack {
                    Label {
                        Text(String(localized: "home_inbox"))
                    } icon: {
                        ListIconView(
                            icon: "tray.and.arrow.down.fill",
                            foregroundColor: .white,
                            backgroundColor: .blue
                        )
                    }

                    Spacer()

                    if badge > 0 {
                        BadgeView(badge: badge)
                    }
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

internal struct NotificationsSection_Previews: PreviewProvider {
    internal static var previews: some View {
        @State var hasNotificationsAndPermission = false
        NotificationsSection(
            hasNotificationsAndPermission: $hasNotificationsAndPermission,
            hasNotificationsEnabled: false,
            allowedUi: false,
            subscriptionToken: "12345",
            notificationsPermission: HomeViewModel.NotificationsPermissionStatus.granted,
            badge: 2,
            updateNotificationsStatus: { _ in }
        )
    }
}
