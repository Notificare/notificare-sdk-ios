//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct JSON {
    public private(set) var value: Any

    public init() {
        value = NSNull()
    }

    public init(_ value: Any?) {
        if let val = value {
            // TODO: check if jsonable
            self.value = val
        } else {
            self.value = NSNull()
        }
    }
}
