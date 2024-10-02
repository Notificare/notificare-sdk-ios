//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

internal var logger: NotificareLogger = {
    var logger = NotificareLogger(
        subsystem: "re.notifica.inbox.user",
        category: "NotificareUserInbox"
    )

    logger.labelIgnoreList.append("NotificareUserInbox")

    return logger
}()
