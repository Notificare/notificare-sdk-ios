//
//  NotificareLogger.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation

public struct NotificareLogger {

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        self.dateFormatter = formatter
    }

    private let dateFormatter: DateFormatter

    public var level: Level = .info


    public func debug(_ message: String) {
        self.log(message, level: .debug)
    }

    public func info(_ message: String) {
        self.log(message, level: .info)
    }

    public func warning(_ message: String) {
        self.log(message, level: .warning)
    }

    public func error(_ message: String) {
        self.log(message, level: .error)
    }


    private func log(_ message: String, level: Level) {
        guard level >= self.level else {
            return
        }

        let date = self.dateFormatter.string(from: Date())

        print("\(date) Notificare/\(level): \(message)")
    }

    public enum Level: String {
        case verbose
        case debug
        case info
        case warning
        case error
    }
}

extension NotificareLogger.Level {
    var severity: Int {
        switch self {
        case .verbose:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .warning:
            return 3
        case .error:
            return 4
        }
    }
}

extension NotificareLogger.Level: Comparable {
    public static func <(lhs: NotificareLogger.Level, rhs: NotificareLogger.Level) -> Bool {
        return lhs.severity < rhs.severity
    }
}
