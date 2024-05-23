//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension Notificare {
    public func push() -> NotificarePush {
        NotificarePushImpl.instance
    }
}

extension Notificare {
    internal func deviceInternal() -> NotificareInternalDeviceModule {
        device() as! NotificareInternalDeviceModule
    }

    internal func pushImplementation() -> NotificarePushImpl {
        NotificarePushImpl.instance
    }
}
