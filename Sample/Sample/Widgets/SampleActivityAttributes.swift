//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import ActivityKit
import Foundation

struct SampleActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let value: Int
    }

    let text: String
}
