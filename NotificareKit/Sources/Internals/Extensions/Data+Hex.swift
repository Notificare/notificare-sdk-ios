//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public extension Data {
    func toHexString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
