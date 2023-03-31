//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Foundation

extension CoffeeBrewerActivityAttributes.ContentState {
    var localizedTimeRemaining: String {
        let localizationKey = NSLocalizedString("coffee_headline_pick_up_minutes", comment: "")
        return String(format: localizationKey, remaining)
    }
}
