//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct TagsView: View {
    @StateObject var viewModel: TagsViewModel
    
    var body: some View {
        List {
            Section {
                if viewModel.deviceTags.isEmpty {
                    Label(String(localized: "tags_no_tags_found"), systemImage: "info.circle.fill")
                } else {
                    ForEach(viewModel.deviceTags, id: \.self) { tag in
                        HStack {
                            Text(tag)
                            Spacer()
                            
                            Button(String(localized: "button_remove")) {
                                viewModel.removeTag(tag: tag)
                            }
                        }
                    }
                }
            } header: {
                Text(String(localized: "tags_device_tags"))
            }
            
            Section {
                if !viewModel.availableTags.isEmpty {
                    VStack (alignment: .leading) {
                        Text(String(localized: "tags_select_tag"))
                        HStack {
                            ForEach(viewModel.availableTags) { tag in
                                SelectableChipView(viewModel: viewModel, tag: tag)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    }
                }
                
                HStack {
                    Text(String(localized: "tags_manual_input"))
                        .frame(maxWidth: .infinity,  alignment: .leading)
                    TextField("Tag", text: $viewModel.inputTag)
                        .frame(maxWidth: .infinity)
                }
                
                Button(String(localized: "button_add")) {
                    viewModel.addTags()
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.selectedTags.isEmpty && viewModel.inputTag.isEmpty)
            } header: {
                Text(String(localized: "tags_quick_fill"))
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                HStack {
                    Button {
                        viewModel.getDeviceTags()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    
                    Button {
                        viewModel.clearTags()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
        )
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView(viewModel: TagsViewModel())
    }
}
