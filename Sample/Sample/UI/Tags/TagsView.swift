//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct TagsView: View {
    @StateObject private var viewModel = TagsViewModel()
    @State private var presentedAlert: PresentedAlert?

    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .idle:
                EmptyView()

            case .loading:
                ProgressView()

            case .success:
                TagsSuccessView(
                    tags: viewModel.deviceTags,
                    selectableTags: $viewModel.selectableTags,
                    input: $viewModel.input,
                    onSaveClicked: {
                        viewModel.saveChanges()
                    },
                    onRemoveClicked: { tag in
                        viewModel.removeTag(tag)
                    }
                )

            case .failure:
                Label {
                    Text(String(localized: "error"))
                } icon: {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.viewState == .success || viewModel.viewState == .failure {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }

                if viewModel.viewState == .success {
                    Button {
                        viewModel.clearTags()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert(item: $presentedAlert, content: createPresentedAlert)
        .onChange(of: viewModel.userMessages) { userMessages in
            if presentedAlert != nil { return }

            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .addTagsSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .addTagsFailure:
                presentedAlert = PresentedAlert(variant: .addTagsFailure, userMessageId: userMessage.uniqueId)

            case .removeTagSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .removeTagFailure:
                presentedAlert = PresentedAlert(variant: .removeTagFailure, userMessageId: userMessage.uniqueId)

            case .clearTagsSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .clearTagsFailure:
                presentedAlert = PresentedAlert(variant: .clearTagsFailure, userMessageId: userMessage.uniqueId)

            case .fetchTagsSuccess:
                viewModel.processUserMessage(userMessage.uniqueId)

            case .fetchTagsFailure:
                presentedAlert = PresentedAlert(variant: .fetchagsFailure, userMessageId: userMessage.uniqueId)
            }
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .fetchagsFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_tags_fetch")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .addTagsFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_tags_add")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .removeTagFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_tags_remove")),
                dismissButton: .default(Text(String(localized: "button_ok"))) {
                    presentedAlert = nil
                    viewModel.processUserMessage(alert.userMessageId)
                }
            )

        case .clearTagsFailure:
            return Alert(
                title: Text(String(localized: "error")),
                message: Text(String(localized: "error_message_tags_clear")),
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
            case fetchagsFailure
            case addTagsFailure
            case removeTagFailure
            case clearTagsFailure
        }
    }
}

private struct TagsSuccessView: View {
    let tags: [String]
    @Binding var selectableTags: [SelectableTag]
    @Binding var input: String
    let onSaveClicked: () -> Void
    let onRemoveClicked: (String) -> Void

    var body: some View {
        List {
            DeviceTagsSectionView(
                tags: tags,
                onRemoveClicked: onRemoveClicked
            )

            SelectableTagsSectionView(
                tags: $selectableTags,
                input: $input,
                onSaveClicked: onSaveClicked
            )
        }
    }
}

private struct DeviceTagsSectionView: View {
    let tags: [String]
    let onRemoveClicked: (String) -> Void

    var body: some View {
        Section {
            if tags.isEmpty {
                Label(String(localized: "tags_no_tags_found"), systemImage: "info.circle.fill")
            } else {
                ForEach(tags, id: \.self) { tag in
                    HStack {
                        Text(tag)

                        Spacer()

                        Button(String(localized: "button_remove")) {
                            onRemoveClicked(tag)
                        }
                    }
                }
            }
        } header: {
            Text(String(localized: "tags_device_tags"))
        }
    }
}

private struct SelectableTagsSectionView: View {
    @Binding var tags: [SelectableTag]
    @Binding var input: String
    let onSaveClicked: () -> Void

    var body: some View {
        Section {
            if !tags.isEmpty {
                VStack(alignment: .leading) {
                    Text(String(localized: "tags_select_tag"))

                    HStack {
                        ForEach($tags) { $tag in
                            SelectableChipView(
                                text: tag.tag,
                                isSelected: $tag.isSelected
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
            }

            HStack {
                Text(String(localized: "tags_manual_input"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Tag", text: $input)
                    .frame(maxWidth: .infinity)
            }

            Button(String(localized: "button_add")) {
                onSaveClicked()
            }
            .frame(maxWidth: .infinity)
            .disabled(!isSaveAllowed)
        } header: {
            Text(String(localized: "tags_quick_fill"))
        }
    }

    private var isSaveAllowed: Bool {
        !tags.filter(\.isSelected).isEmpty || !input.isEmpty
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView()
    }
}
