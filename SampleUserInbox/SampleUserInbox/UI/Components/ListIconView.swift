//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct ListIconView: View {
    internal let icon: String
    internal let foregroundColor: Color
    internal let backgroundColor: Color

    internal var body: some View {
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

internal struct ListIconView_Previews: PreviewProvider {
    internal static var previews: some View {
        ListIconView(
            icon: "sensor.tag.radiowaves.forward",
            foregroundColor: Color.white,
            backgroundColor: Color.blue
        )
    }
}
