//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

internal enum UserInboxError: Error {
    case missingClientData
    case noDeviceIdAvailable
    case couldNotClearCredentials
    case noStoredCredentionals
}
