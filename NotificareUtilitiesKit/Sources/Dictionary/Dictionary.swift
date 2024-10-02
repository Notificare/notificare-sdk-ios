//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension Dictionary {
    /// Same values, corresponding to `map`ped keys.
    ///
    /// - Parameter transform: Accepts each key of the dictionary as its parameter
    ///   and returns a key for the new dictionary.
    /// - Postcondition: The collection of transformed keys must not contain duplicates.
    public func mapKeys<Transformed>(
        _ transform: (Key) throws -> Transformed
    ) rethrows -> [Transformed: Value] {
        try .init(
            uniqueKeysWithValues: map {
                try (transform($0.key), $0.value)
            }
        )
    }
}
