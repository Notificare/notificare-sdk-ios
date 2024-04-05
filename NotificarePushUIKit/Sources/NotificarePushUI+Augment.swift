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

extension Notificare {
    internal func pushUIImplementation() -> NotificarePushUIImpl {
        NotificarePushUIImpl.instance
    }
}
