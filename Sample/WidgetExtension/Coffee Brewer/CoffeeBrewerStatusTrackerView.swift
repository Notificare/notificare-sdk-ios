//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct CoffeeBrewerStatusTrackerView: View {
    let state: CoffeeBrewerActivityAttributes.BrewingState

    var body: some View {
        HStack(spacing: 8) {
            BrewingProgressView(
                currentState: state,
                representedState: .grinding
            )

            BrewingProgressBarView(
                currentState: state,
                representedState: .brewing
            )

            BrewingProgressView(
                currentState: state,
                representedState: .brewing
            )

            BrewingProgressBarView(
                currentState: state,
                representedState: .served
            )

            BrewingProgressView(
                currentState: state,
                representedState: .served
            )
        }
    }
}

private struct BrewingProgressView: View {
    let currentState: CoffeeBrewerActivityAttributes.BrewingState
    let representedState: CoffeeBrewerActivityAttributes.BrewingState

    var body: some View {
        Image(icon)
            .resizable()
            .scaledToFit()
            .foregroundColor(foregroundColor)
            .padding(4)
            .frame(width: 24, height: 24)
            .background(backgroundColor)
            .clipShape(Circle())
    }

    private var icon: String {
        switch representedState {
        case .grinding:
            return "ic_coffee_beans"

        case .brewing:
            return "ic_coffee_pot"

        case .served:
            return "ic_coffee_cup"
        }
    }

    private var foregroundColor: Color {
        if representedState.index <= currentState.index {
            return .white
        } else {
            return .black
        }
    }

    private var backgroundColor: Color {
        if representedState.index <= currentState.index {
            return Color("color_coffee")
        } else {
            return Color("color_disabled_grey")
        }
    }
}

private struct BrewingProgressBarView: View {
    let currentState: CoffeeBrewerActivityAttributes.BrewingState
    let representedState: CoffeeBrewerActivityAttributes.BrewingState

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .frame(height: 4)
    }

    private var fillColor: Color {
        if representedState.index <= currentState.index {
            return Color("color_coffee")
        } else {
            return Color("color_disabled_grey")
        }
    }
}

struct CoffeeBrewerStatusTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeBrewerStatusTrackerView(state: .brewing)
    }
}
