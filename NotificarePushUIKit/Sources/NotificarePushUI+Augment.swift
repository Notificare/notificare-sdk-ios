//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension Notificare {
    public func pushUI() -> NotificarePushUI {
        NotificarePushUIImpl.instance
    }
}

extension Notificare {
    internal func pushUIImplementation() -> NotificarePushUIImpl {
        NotificarePushUIImpl.instance
    }
}
