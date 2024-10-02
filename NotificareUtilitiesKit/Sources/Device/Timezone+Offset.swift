//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

extension TimeZone {
    public var timeZoneOffset: Float {
        return Float(secondsFromGMT()) / 3600.0
    }
}
