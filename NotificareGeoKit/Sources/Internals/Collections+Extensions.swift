//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension Set {
    func appending(_ element: Element) -> Self {
        var copy = self
        copy.insert(element)

        return copy
    }

    func removing(_ element: Element) -> Self {
        var copy = self
        copy.remove(element)

        return copy
    }
}
