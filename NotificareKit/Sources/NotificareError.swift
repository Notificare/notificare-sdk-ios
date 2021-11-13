//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareError: Error {
    case notConfigured
    case notReady
    case deviceUnavailable
    case applicationUnavailable
    case serviceUnavailable(service: String)

    // supporting errors
    case invalidArgument(message: String)
}
