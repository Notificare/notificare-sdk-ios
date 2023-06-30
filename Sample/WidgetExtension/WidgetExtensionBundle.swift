//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            CoffeeBrewerLiveActivity()
        }
    }
}
