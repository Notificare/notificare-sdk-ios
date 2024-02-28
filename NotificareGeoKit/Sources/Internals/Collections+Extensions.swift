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

internal extension Array {
    /// Returns a list of `n` evenly spaced elements.
    ///
    /// - Parameter n: the number of elements to extract.
    /// - Returns: A list of `n` evenly spaced elements.
    func takeEvenlySpaced(_ n: Int) -> Array<Element> {
        guard n >= 0 else {
            fatalError("Requested element count \(n) is less than zero.")
        }

        let interval = (Double(count) - 1) / (Double(n) - 1)
        var elements: [Element] = []

        for i in 0..<n {
            let index = Int(round(interval * Double(i)))
            elements.append(self[index])
        }

        return elements
    }
}
