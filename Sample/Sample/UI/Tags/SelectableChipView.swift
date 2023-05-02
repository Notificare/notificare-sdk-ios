//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct SelectableChipView: View {
    @StateObject var viewModel: TagsViewModel
    @State var tag: AvailableTag

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name).font(.body).lineLimit(1)
        }
        .padding(.vertical, 8)
        .padding([.trailing, .leading], 16)
        .foregroundColor(Color.white)
        .background(tag.isSelected ? Color.blue : Color.black)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(tag.isSelected ? Color.blue : Color.black, lineWidth: 1.5)
        )
        .onTapGesture {
            tag.isSelected.toggle()
            viewModel.handleSelectedTag(tag: tag.name)
        }
    }
}

struct SelectableChipView_Previews: PreviewProvider {
    static var previews: some View {
        SelectableChipView(viewModel: TagsViewModel(), tag: AvailableTag(name: "Java", isSelected: false))
    }
}
