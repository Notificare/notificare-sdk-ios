//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

internal extension String {
    func toRegex() -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: self)
        } catch {
            preconditionFailure("Illegal regular expression: \(self).")
        }
    }
}

internal extension String {
    func matches(_ regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}
