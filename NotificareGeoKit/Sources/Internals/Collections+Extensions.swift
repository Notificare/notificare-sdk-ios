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

    func appending<S>(contentsOf newElements: S) -> Self where S: Sequence, Element == S.Element {
        var copy = self
        newElements.forEach { copy.insert($0) }

        return copy
    }

    func removing(_ element: Element) -> Self {
        var copy = self
        copy.remove(element)

        return copy
    }
}

internal extension Array {
    func appending(_ element: Element) -> Self {
        var copy = self
        copy.append(element)

        return copy
    }
}
