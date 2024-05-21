//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension Notificare {
    public func inbox() -> NotificareInbox {
        NotificareInboxImpl.instance
    }
}
