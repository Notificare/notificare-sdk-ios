//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public protocol NotificareAssets: AnyObject {
    func fetch(group: String, _ completion: @escaping NotificareCallback<[NotificareAsset]>)

    @available(iOS 13.0, *)
    func fetch(group: String) async throws -> [NotificareAsset]
}
