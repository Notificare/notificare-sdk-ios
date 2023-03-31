//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import SwiftUI

struct AsyncImageCompat<Placeholder: View, Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: () -> Placeholder
    private let image: (UIImage) -> Content
    
    init(
        url: URL?,
        @ViewBuilder image: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.placeholder = placeholder
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }
    
    var body: some View {
        Group {
            if loader.image != nil {
                image(loader.image!)
            } else {
                placeholder()
            }
        }
        .onAppear(perform: loader.load)
    }
}

struct AsyncImageCompat_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageCompat(
            url: URL(string: "https://image.tmdb.org/t/p/original//pThyQovXQrw2m0s9x82twj48Jq4.jpg")!,
            image: { Image(uiImage: $0) },
            placeholder: { ProgressView() }
        )
    }
}
