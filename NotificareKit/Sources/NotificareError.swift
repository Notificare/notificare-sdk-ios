//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareError: Error {
    case generic(message: String, cause: Error? = nil)

    case notReady
    case networkFailure(cause: NotificareNetworkError)
    case encodingFailure
    case parsingFailure
    case invalidLanguageCode
    case invalidArgument

    case applicationUnavailable
    case serviceUnavailable(module: String)
}
