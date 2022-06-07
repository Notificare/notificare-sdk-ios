//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension Notificare {
    func pushUI() -> NotificarePushUI {
        NotificarePushUIImpl.instance
    }
}

internal extension Notificare {
    func pushUIImplementation() -> NotificarePushUIImpl {
        NotificarePushUIImpl.instance
    }
}
