//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension Set {
    internal func appending(_ element: Element) -> Self {
        var copy = self
        copy.insert(element)

        return copy
    }

    internal func appending<S>(contentsOf newElements: S) -> Self where S: Sequence, Element == S.Element {
        var copy = self
        newElements.forEach { copy.insert($0) }

        return copy
    }

    internal func removing(_ element: Element) -> Self {
        var copy = self
        copy.remove(element)

        return copy
    }
}

extension Array {
    internal func appending(_ element: Element) -> Self {
        var copy = self
        copy.append(element)

        return copy
    }
}

extension Array {
    /// Returns a list of `n` evenly spaced elements.
    ///
    /// - Parameter n: the number of elements to extract.
    /// - Returns: A list of `n` evenly spaced elements.
    internal func takeEvenlySpaced(_ n: Int) -> [Element] {
        guard n >= 0 else {
            fatalError("Requested element count \(n) is less than zero.")
        }

        guard count > n else {
            return self
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
