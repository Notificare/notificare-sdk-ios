//
// Copyright (c) 2024 Notificare. All rights reserved.
//
import NotificareKit
import NotificareUtilitiesKit

internal var logger: NotificareLogger = {
    var logger = NotificareLogger(
        subsystem: "re.notifica.notificationServiceExtension",
        category: "NotificareServiceExtension"
    )
    logger.hasDebugLoggingEnabled = Notificare.shared.options?.debugLoggingEnabled ?? false

    return logger
}()
