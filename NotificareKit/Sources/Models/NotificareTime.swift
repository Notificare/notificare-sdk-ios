//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareTime {
    public let hours: Int
    public let minutes: Int

    public init(hours: Int, minutes: Int) throws {
        if 0 ... 23 ~= hours, 0 ... 59 ~= minutes {
            self.hours = hours
            self.minutes = minutes
        } else {
            throw NotificareError.invalidArgument
        }
    }

    public init(string: String) throws {
        let parts = string.components(separatedBy: ":")

        guard parts.count == 2,
            let hours = Int(parts[0]),
            let minutes = Int(parts[1])
        else {
            throw NotificareError.invalidArgument
        }

        try self.init(hours: hours, minutes: minutes)
    }

    public func format() -> String {
        String(format: "%02d:%02d", hours, minutes)
    }
}

extension NotificareTime: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        try self.init(string: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(format())
    }
}
