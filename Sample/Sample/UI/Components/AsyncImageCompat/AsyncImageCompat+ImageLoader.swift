//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import Combine
import Foundation
import UIKit

internal class ImageLoader: ObservableObject {
    @Published internal  var image: UIImage?

    internal private(set) var isLoading = false

    private let url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?

    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")

    internal init(url: URL?, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }

    deinit {
        cancel()
    }

    internal func load() {
        guard !isLoading else { return }

        if url == nil {
            image = nil
            return
        }

        if let image = cache?[url!] {
            self.image = image
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url!)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    internal func cancel() {
        cancellable?.cancel()
    }

    private func onStart() {
        isLoading = true
    }

    private func onFinish() {
        isLoading = false
    }

    private func cache(_ image: UIImage?) {
        image.map { cache?[url!] = $0 }
    }
}
