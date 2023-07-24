//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct CoffeeBrewerHeadlineView: View {
    var alignment: HorizontalAlignment = .center
    let state: CoffeeBrewerActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: alignment) {
            HStack(spacing: 0) {
                Text("\(title) ")

                if state.state != .served {
                    Text(state.localizedTimeRemaining)
                        .foregroundColor(.green)
                }
            }
            .font(.headline)

            Text(subtitle)
                .font(.footnote)
        }
    }

    private var title: String {
        if state.state == .served {
            return String(localized: "coffee_headline_served_title")
        } else {
            return String(localized: "coffee_headline_pick_up_title")
        }
    }

    private var subtitle: String {
        switch state.state {
        case .served:
            return String(localized: "coffee_headline_served_subtitle")

        case .brewing:
            return String(localized: "coffee_headline_brewing_subtitle")

        case .grinding:
            return String(localized: "coffee_headline_grinding_subtitle")
        }
    }
}

struct CoffeeBrewerHeadlineView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBrewerHeadlineView(
            state: CoffeeBrewerActivityAttributes.ContentState(
                state: .brewing,
                remaining: 5
            )
        )
    }
}
