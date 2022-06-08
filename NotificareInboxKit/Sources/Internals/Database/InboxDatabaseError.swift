//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

internal enum InboxDatabaseError: Error {
    case invalidArgument(_ argument: String, cause: Error?)
}
