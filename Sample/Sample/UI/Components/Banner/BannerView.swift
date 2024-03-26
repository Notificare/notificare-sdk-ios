//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

internal struct BannerView: View {
    internal var title: String? = nil
    internal var subtitle: String? = nil

    internal var body: some View {
        VStack {
            if let title {
                Text(title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
            }

            if let subtitle {
                Text(subtitle)
                    .font(.footnote.bold())
                    .foregroundColor(Color(.systemGray))
                    .lineLimit(1)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 4, y: 6)
        .padding()
    }
}

#Preview {
    BannerView(
        title: "Hello there",
        subtitle: "General Kenobi"
    )
}
