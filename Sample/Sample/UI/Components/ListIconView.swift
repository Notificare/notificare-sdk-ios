//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct ListIconView: View {
    let icon: String
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(6)
            .frame(width: 28, height: 28, alignment: .center)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ListIconView_Previews: PreviewProvider {
    static var previews: some View {
        ListIconView(
            icon: "sensor.tag.radiowaves.forward",
            foregroundColor: Color.white,
            backgroundColor: Color.blue
        )
    }
}
