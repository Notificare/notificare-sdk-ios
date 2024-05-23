//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

extension Notificare {
    public func inAppMessaging() -> NotificareInAppMessaging {
        NotificareInAppMessagingImpl.instance
    }
}
