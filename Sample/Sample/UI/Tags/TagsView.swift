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
                Text("ooops")
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
        .onReceive(viewModel.$userMessages) { userMessages in
            guard let userMessage = userMessages.first else {
                return
            }

            switch userMessage.variant {
            case .addTagsSuccess:
                break

            case .addTagsFailure:
                presentedAlert = PresentedAlert(variant: .addTagsFailure)

            case .removeTagSuccess:
                break

            case .removeTagFailure:
                presentedAlert = PresentedAlert(variant: .removeTagFailure)

            case .clearTagsSuccess:
                break

            case .clearTagsFailure:
                presentedAlert = PresentedAlert(variant: .clearTagsFailure)
            }

            viewModel.processUserMessage(userMessage)
        }
    }

    private func createPresentedAlert(_ alert: PresentedAlert) -> Alert {
        switch alert.variant {
        case .addTagsFailure:
            return Alert(
                title: Text(String(localized: "shared_alert_title_error")),
                message: Text(String(localized: "tags_alert_add_tags_error_message")),
                dismissButton: .default(Text(String(localized: "shared_alert_ok_button")))
            )

        case .removeTagFailure:
            return Alert(
                title: Text(String(localized: "shared_alert_title_error")),
                message: Text(String(localized: "tags_alert_remove_tag_error_message")),
                dismissButton: .default(Text(String(localized: "shared_alert_ok_button")))
            )

        case .clearTagsFailure:
            return Alert(
                title: Text(String(localized: "shared_alert_title_error")),
                message: Text(String(localized: "tags_alert_clear_tags_error_message")),
                dismissButton: .default(Text(String(localized: "shared_alert_ok_button")))
            )
        }
    }

    private struct PresentedAlert: Identifiable {
        let id = UUID().uuidString
        let variant: Variant

        enum Variant {
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
            .disabled(isSaveAllowed)
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
