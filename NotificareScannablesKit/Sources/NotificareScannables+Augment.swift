//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension Notificare {
    public func scannables() -> NotificareScannables {
        NotificareScannablesImpl.instance
    }
}
