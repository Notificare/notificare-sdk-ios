//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import ActivityKit
import Foundation

internal struct CoffeeBrewerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        internal var state: BrewingState
        internal var remaining: Int
    }

    public enum BrewingState: String, Codable, CaseIterable {
        case grinding
        case brewing
        case served

        internal var index: Int {
            guard let index = Self.allCases.firstIndex(of: self) else {
                return 0
            }

            return Self.allCases.distance(
                from: Self.allCases.startIndex,
                to: index
            )
        }
    }
}
