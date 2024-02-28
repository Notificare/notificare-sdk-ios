//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

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
