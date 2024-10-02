//
// Copyright (c) 2024 Notificare. All rights reserved.
//

internal var logger: NotificareLogger = {
    var logger = NotificareLogger(
        subsystem: "re.notifica.utilities",
        category: "NotificareUtilities"
    )

    return logger
}()
