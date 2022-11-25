//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

public extension Notificare {
    func userInbox() -> NotificareUserInbox {
        NotificareUserInboxImpl.instance
    }
}
