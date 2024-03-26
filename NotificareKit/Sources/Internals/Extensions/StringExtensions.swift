//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension String {
    internal func toRegex() -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: self)
        } catch {
            preconditionFailure("Illegal regular expression: \(self).")
        }
    }
}

extension String {
    internal func matches(_ regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

extension String {
    internal func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }

        return String(dropLast(suffix.count))
    }
}
