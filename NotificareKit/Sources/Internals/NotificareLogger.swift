//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import os

public class NotificareLogger {
    @available(iOS 14.0, *)
    private lazy var logger = Logger(subsystem: "re.notifica", category: "Notificare")

    private let osLog = OSLog(subsystem: "re.notifica", category: "Notificare")

    public var level: Level = .info

    public func verbose(_ message: String, file: String = #file) {
        log(message, level: .verbose, file: file)
    }

    public func verbose(_ message: String, tag: String?) {
        log(message, level: .verbose, tag: tag)
    }

    public func debug(_ message: String, file: String = #file) {
        log(message, level: .debug, file: file)
    }

    public func debug(_ message: String, tag: String?) {
        log(message, level: .debug, tag: tag)
    }

    public func info(_ message: String, file: String = #file) {
        log(message, level: .info, file: file)
    }

    public func info(_ message: String, tag: String?) {
        log(message, level: .info, tag: tag)
    }

    public func warning(_ message: String, file: String = #file) {
        log(message, level: .warning, file: file)
    }

    public func warning(_ message: String, tag: String?) {
        log(message, level: .warning, tag: tag)
    }

    public func error(_ message: String, file: String = #file) {
        log(message, level: .error, file: file)
    }

    public func error(_ message: String, tag: String?) {
        log(message, level: .error, tag: tag)
    }

    private func log(_ message: String, level: Level, file: String = #file) {
        if let fileName = URL(fileURLWithPath: file).pathComponents.last,
           let tag = fileName.split(separator: ".").first
        {
            log(message, level: level, tag: String(tag))
        } else {
            log(message, level: level, tag: file)
        }
    }

    private func log(_ message: String, level: Level, tag: String?) {
        guard level >= self.level else {
            return
        }

        let combined: String
        if let tag = tag {
            combined = "[\(tag)] \(message)"
        } else {
            combined = message
        }

        if #available(iOS 14, *) {
            self.logger.log(level: level.toOSLogType(), "\(combined, privacy: .public)")
        } else {
            os_log("%{public}s", log: osLog, type: level.toOSLogType(), combined)
        }
    }

    public enum Level: String {
        case verbose
        case debug
        case info
        case warning
        case error
    }
}

extension NotificareLogger.Level: Comparable {
    private var severity: Int {
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

    public static func < (lhs: NotificareLogger.Level, rhs: NotificareLogger.Level) -> Bool {
        lhs.severity < rhs.severity
    }
}

extension NotificareLogger.Level {
    func toOSLogType() -> OSLogType {
        switch self {
        case .verbose, .debug:
            return .debug
        case .info:
            return .default
        case .warning, .error:
            return .error
        }
    }
}
