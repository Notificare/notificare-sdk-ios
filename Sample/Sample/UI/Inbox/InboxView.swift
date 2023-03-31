//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import NotificareKit
import NotificareInboxKit
import NotificarePushUIKit
import OSLog

struct InboxView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: InboxViewModel
    @State private var actionableItem: NotificareInboxItem?
    
    init() {
        self._viewModel = StateObject(wrappedValue: InboxViewModel())
    }
    
    var body: some View {
        ZStack {
            if viewModel.sections.isEmpty {
                Text(String(localized: "inbox_no_messages"))
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .padding(.all, 32)
            } else {
                List {
                    ForEach(viewModel.sections, id: \.group) { section in
                        Section {
                            ForEach(section.items) { item in
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
                        } header: {
                            Text(verbatim: viewModel.getSectionHeader(section))
                        }
                    }
                }
                .customListStyle()
            }
        }
        .navigationTitle(String(localized: "inbox_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !viewModel.sections.isEmpty {
                    Button(action: viewModel.handleMarkAllItemsAsRead) {
                        Image(systemName: "envelope.open")
                    }
                    
                    Button(action: viewModel.handleClearItems) {
                        Image(systemName: "trash")
                    }
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
                        viewModel.handleMarkItemAsRead(item)
                    },
                    .destructive(Text(String(localized: "inbox_sheet_remove"))) {
                        viewModel.handleRemoveItem(item)
                    },
                    .default(Text(String(localized: "inbox_sheet_cancel"))) { }
                ]
            )
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
