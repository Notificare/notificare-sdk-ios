//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension Date {
    public init?(isoDateString: String) {
        guard let date = Date.isoDateParser.date(from: isoDateString) else {
            return nil
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }

    public static let isoDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    public static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    public func toIsoString() -> String {
        return Date.isoDateFormatter.string(from: self)
    }
}
