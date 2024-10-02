//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

internal var logger: NotificareLogger = {
    var logger = NotificareLogger(
        subsystem: "re.notifica.push",
        category: "NotificarePush"
    )

    logger.labelIgnoreList.append("NotificarePush")

    return logger
}()
