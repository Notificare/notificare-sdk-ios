//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public class NotificareImageCache {
    private let session = URLSession(configuration: .default)

    public private(set) var portraitImage: UIImage?
    public private(set) var landscapeImage: UIImage?

    public var orientationConstrainedImage: UIImage? {
        if UIDevice.current.orientation.isLandscape {
            return landscapeImage ?? portraitImage
        }

        return portraitImage ?? landscapeImage
    }

    internal func preloadImages(for message: NotificareInAppMessage) async throws {
        self.portraitImage = nil
        self.landscapeImage = nil

        if let urlStr = message.image, let url = URL(string: urlStr) {
            let (data, _) = try await session.data(from: url)

            guard let image = UIImage(data: data) else {
                throw Error.invalidImage
            }

            portraitImage = image
        }

        if let urlStr = message.landscapeImage, let url = URL(string: urlStr) {
            let (data, _) = try await session.data(from: url)

            guard let image = UIImage(data: data) else {
                throw Error.invalidImage
            }

            landscapeImage = image
        }
    }

    public enum Error: Swift.Error {
        case invalidImage
    }
}
