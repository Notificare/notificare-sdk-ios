//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var presentedAlert: PresentedAlert?

    internal var body: some View {
        List {
            AuthenticationSection(
                isLoggedIn: viewModel.isLoggedIn,
                isDeviceRegistered: viewModel.isDeviceRegistered,
                startLoginFlow: { viewModel.startLoginFlow() },
                startLogoutFlow: { viewModel.startLogoutFlow() }
            )

            LaunchFlowSection(
                isReady: viewModel.isReady,
                isConfigured: viewModel.isConfigured,
                isDeviceRegistered: viewModel.isDeviceRegistered,
                launch: { viewModel.notificareLaunch() },
                unlaunch: { viewModel.notificareUnlaunch() }
            )

            NotificationsSection(
                hasNotificationsAndPermission: $viewModel.hasNotificationsAndPermission,
                hasNotificationsEnabled: viewModel.hasNotificationsEnabled,
                allowedUi: viewModel.allowedUi,
                notificationsPermission: viewModel.notificationsPermission,
                badge: viewModel.badge,
                updateNotificationsStatus: { enable in viewModel.updateNotificationsStatus(enabled: enable) }
            )

            DoNotDisturbSection(
                hasDndEnabled: $viewModel.hasDndEnabled,
                startTime: $viewModel.startTime,
                endTime: $viewModel.endTime,
                updateDndStatus: { enabled in viewModel.updateDndStatus(enabled: enabled) },
                updateDndTime: { viewModel.updateDndTime() }
            )

            if let applicationInfo = viewModel.applicationInfo {
                ApplicationInfoSection(
                    applicationName: applicationInfo.name,
                    applicationIdentifier: applicationInfo.identifier
                )
            }
        }
        .navigationTitle(String(localized: "home_title"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $presentedAlert, content: createPresentedAlert)
        .onChange(of: viewModel.userMessages) { userMessages in
            if presentedAlert != nil { return }

            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .requestNotificationsPermissionSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .requestNotificationsPermissionFailure:
                presentedAlert = PresentedAlert(variant: .requestNotificationsPermissionFailure, userMessageId: userMessage.uniqueId)

            case .enableRemoteNotificationsSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .enableRemoteNotificationsFailure:
                presentedAlert = PresentedAlert(variant: .enableRemoteNotificationsFailure, userMessageId: userMessage.uniqueId)

            case .clearDoNotDisturbSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clearDoNotDisturbFailure:
                presentedAlert = PresentedAlert(variant: .clearDoNotDisturbFailure, userMessageId: userMessage.uniqueId)

            case .updateDoNotDisturbSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .updateDoNotDisturbFailure:
                presentedAlert = PresentedAlert(variant: .updateDoNotDisturbFailure, userMessageId: userMessage.uniqueId)

            case .updateBadgeSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .updateBadgeFailure:
                presentedAlert = PresentedAlert(variant: .updateBadgeFailure, userMessageId: userMessage.uniqueId)

            case .clientLoginFlowSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clientLoginFlowFailure:
                presentedAlert = PresentedAlert(variant: .loginFlowFailure, userMessageId: userMessage.uniqueId)

            case .clientLogoutFlowSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clientLogoutFlowFailure:
                presentedAlert = PresentedAlert(variant: .logoutFlowFailure, userMessageId: userMessage.uniqueId)
            }
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .requestNotificationsPermissionFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_notifications_permission")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .enableRemoteNotificationsFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_enable_remote_notifications")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .clearDoNotDisturbFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_clear_dnd")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .updateDoNotDisturbFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_update_dnd")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .loginFlowFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_client_login")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .logoutFlowFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_client_logout")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .updateBadgeFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_home_update_badge")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )
        }
    }

    private struct PresentedAlert: Identifiable {
        let id = UUID().uuidString
        let variant: Variant
        let userMessageId: String

        enum Variant {
            case requestNotificationsPermissionFailure
            case enableRemoteNotificationsFailure
            case clearDoNotDisturbFailure
            case updateDoNotDisturbFailure
            case updateBadgeFailure
            case loginFlowFailure
            case logoutFlowFailure
        }
    }
}

internal struct HomeView_Previews: PreviewProvider {
    internal static var previews: some View {
        HomeView()
    }
}
