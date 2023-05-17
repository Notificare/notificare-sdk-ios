//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct SelectableChipView: View {
    let text: String
    @Binding var isSelected: Bool

    var body: some View {
        Text(text)
            .font(.body)
            .lineLimit(1)
            .padding(.vertical, 8)
            .padding([.trailing, .leading], 16)
            .foregroundColor(Color.white)
            .background(backgroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(backgroundColor, lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                isSelected = !isSelected
            }
    }

    private var backgroundColor: Color {
        isSelected ? Color.blue : Color.black
    }
}

struct SelectableChipView_Previews: PreviewProvider {
    @State static var isSelected = false

    static var previews: some View {
        SelectableChipView(
            text: "Foo",
            isSelected: $isSelected
        )
    }
}
