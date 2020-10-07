//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareError: Error {
    case notConfigured
    case networkFailure(cause: NotificareNetworkError)
    case encodingFailure
    case parsingFailure
    case noDevice
}