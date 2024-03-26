//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension Notificare {
    func push() -> NotificarePush {
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
