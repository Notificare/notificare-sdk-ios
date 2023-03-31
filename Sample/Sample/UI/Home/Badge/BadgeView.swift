//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct BadgeView: View {
    @State private var height: CGFloat = 0
    
    let badge: Int
    
    var body: some View {
        Text(verbatim: "\(badge)")
            .font(.caption)
            .foregroundColor(.white)
            .padding(4)
            .frame(minWidth: height)
            .background(Color.red)
            .clipShape(Capsule())
            .overlay(DetermineSize())
            .onPreferenceChange(DetermineSize.Key.self) { size in
                height = size.height
            }
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            BadgeView(badge: 5)
            BadgeView(badge: 15)
            BadgeView(badge: 105)
        }
    }
}
