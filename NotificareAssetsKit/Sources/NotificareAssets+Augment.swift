//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension Notificare {
    func assets() -> NotificareAssets {
        NotificareAssetsImpl.instance
    }
}
