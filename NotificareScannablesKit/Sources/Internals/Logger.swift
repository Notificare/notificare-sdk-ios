//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

internal var logger: NotificareLogger = {
    var logger = NotificareLogger(
        subsystem: "re.notifica.scannables",
        category: "NotificareScannables"
    )

    logger.labelIgnoreList.append("NotificareScannables")

    return logger
}()
