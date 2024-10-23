//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareUserInboxKit
import NotificareKit
import NotificarePushUIKit
import OSLog
import SwiftUI

internal struct InboxView: View {
    @Environment(\.presentationMode) internal var presentationMode
    @StateObject private var viewModel = InboxViewModel()
    @State private var actionableItem: NotificareUserInboxItem?
    @State private var presentedAlert: PresentedAlert?

    internal var body: some View {
        ZStack {
            if viewModel.items.isEmpty {
                Text(String(localized: "inbox_no_messages"))
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .padding(.all, 32)
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        InboxItemView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if item.notification.type == NotificareNotification.NotificationType.urlScheme.rawValue {
                                    presentationMode.wrappedValue.dismiss()
                                }

                                viewModel.presentInboxItem(item)
                            }
                            .onLongPressGesture {
                                actionableItem = item
                            }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "inbox_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshInbox()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .actionSheet(item: $actionableItem) { item in
            ActionSheet(
                title: Text(String(localized: "inbox_sheet_select_option")),
                message: Text(item.notification.message),
                buttons: [
                    .default(Text(String(localized: "inbox_sheet_open"))) {
                        viewModel.presentInboxItem(item)
                    },
                    .default(Text(String(localized: "inbox_sheet_mark_as_read"))) {
                        viewModel.markItemAsRead(item)
                    },
                    .destructive(Text(String(localized: "inbox_sheet_remove"))) {
                        viewModel.removeItem(item)
                    },
                    .default(Text(String(localized: "inbox_sheet_cancel"))) {},
                ]
            )
        }
        .alert(item: $presentedAlert, content: createPresentedAlert)
        .onAppear {
            viewModel.refreshInbox()
        }
        .onChange(of: viewModel.userMessages) { userMessages in
            if presentedAlert != nil { return }

            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .presentItemSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .presentItemFailure:
                presentedAlert = PresentedAlert(variant: .presentItemFailure, userMessageId: userMessage.uniqueId)

            case .markItemAsReadSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .markItemAsReadFailure:
                presentedAlert = PresentedAlert(variant: .markItemAsReadFailure, userMessageId: userMessage.uniqueId)

            case .removeItemSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .removeItemFailure:
                presentedAlert = PresentedAlert(variant: .removeItemFailure, userMessageId: userMessage.uniqueId)

            case .refreshInboxSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .refreshInboxFailure:
                presentedAlert = PresentedAlert(variant: .refreshInboxFailure, userMessageId: userMessage.uniqueId)
            }
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .presentItemFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_inbox_present")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .markItemAsReadFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_inbox_mark_as_read")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .removeItemFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_inbox_remove")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .refreshInboxFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_inbox_refresh")),
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
            case presentItemFailure
            case markItemAsReadFailure
            case removeItemFailure
            case refreshInboxFailure
        }
    }
}

internal struct InboxView_Previews: PreviewProvider {
    internal static var previews: some View {
        InboxView()
    }
}
