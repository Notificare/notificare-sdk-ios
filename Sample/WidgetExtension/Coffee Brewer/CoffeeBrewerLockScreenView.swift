//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI
import WidgetKit

struct CoffeeBrewerLockScreenView: View {
    let attributes: CoffeeBrewerActivityAttributes
    let state: CoffeeBrewerActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                CoffeeBrewerHeadlineView(alignment: .leading, state: state)

                Spacer()

                Image("artwork_coffee_pot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }

            CoffeeBrewerStatusTrackerView(state: state.state)
        }
        .padding()
    }
}

struct CoffeeBrewerLiveActivityView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBrewerLockScreenView(
            attributes: CoffeeBrewerActivityAttributes(),
            state: CoffeeBrewerActivityAttributes.ContentState(
                state: .brewing,
                remaining: 1
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
