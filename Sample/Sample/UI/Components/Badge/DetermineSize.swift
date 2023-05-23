//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct DetermineSize: View {
    typealias Key = SizePreferenceKey

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .anchorPreference(key: Key.self, value: .bounds) { anchor in
                    proxy[anchor].size
                }
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
