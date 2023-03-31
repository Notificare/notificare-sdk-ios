//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

extension List {
    @ViewBuilder
    func customListStyle() -> some View {
        if #available(iOS 15.0, *) {
            listStyle(.insetGrouped)
        } else {
            listStyle(.grouped)
        }
    }
}
