//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public enum NotificareIsoDateUtils {
    internal static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = .current

        return formatter
    }()

    internal static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")

        return formatter
    }()

    public static func parse(_ date: String) -> Date? {
        parser.date(from: date)
    }

    public static func format(_ date: Date) -> String {
        formatter.string(from: date)
    }
}
