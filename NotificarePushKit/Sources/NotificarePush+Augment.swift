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

internal extension Notificare {
    func deviceInternal() -> NotificareInternalDeviceModule {
        device() as! NotificareInternalDeviceModule
    }
}
