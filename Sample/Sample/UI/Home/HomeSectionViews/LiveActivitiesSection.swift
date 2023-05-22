//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct LiveActivitiesSection: View {
    let coffeeBrewerLiveActivityState: CoffeeBrewerActivityAttributes.BrewingState?

    var body: some View {
        Section {
            VStack {
                if #available(iOS 16.1, *) {
                    CoffeeBrewerActionsView(state: coffeeBrewerLiveActivityState) {
                        LiveActivitiesController.shared.createCoffeeBrewerLiveActivity()
                    } onNextStep: {
                        LiveActivitiesController.shared.continueCoffeeBrewerLiveActivity()
                    } onCancel: {
                        LiveActivitiesController.shared.cancelCoffeeBrewerLiveActivity()
                    }
                }
            }
        } header: {
            Text(String(localized: "home_coffee_brewer_title"))
        }
    }
}

private struct CoffeeBrewerActionsView: View {
    var state: CoffeeBrewerActivityAttributes.BrewingState?
    var onCreate: () -> Void
    var onNextStep: () -> Void
    var onCancel: () -> Void

    var body: some View {
        if let state {
            VStack(spacing: 16) {
                switch state {
                case .grinding:
                    Button(String(localized: "home_coffee_brewer_brew_button")) {
                        onNextStep()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(BorderlessButtonStyle())

                case .brewing:
                    Button(String(localized: "home_coffee_brewer_serve_button")) {
                        onNextStep()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(BorderlessButtonStyle())

                case .served:
                    EmptyView()
                }

                Button(String(localized: "home_coffee_brewer_stop_button")) {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.red)
            }
        } else {
            Button(String(localized: "home_coffee_brewer_create_button")) {
                onCreate()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct LiveActivitiesSection_Previews: PreviewProvider {
    static var previews: some View {
        LiveActivitiesSection(coffeeBrewerLiveActivityState: .none)
    }
}
