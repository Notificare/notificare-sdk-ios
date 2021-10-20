//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import os

public enum NotificareLogger {
    @available(iOS 14.0, *)
    private static var logger = Logger(subsystem: "re.notifica", category: "Notificare")

    private static let osLog = OSLog(subsystem: "re.notifica", category: "Notificare")

    public static var useAdvancedLogging = false

    public static func debug(_ message: String, file: String = #file) {
        log(message, level: .debug, file: file)
    }

    public static func debug(_ message: String, tag: String?) {
        log(message, level: .debug, tag: tag)
    }

    public static func info(_ message: String, file: String = #file) {
        log(message, level: .info, file: file)
    }

    public static func info(_ message: String, tag: String?) {
        log(message, level: .info, tag: tag)
    }

    public static func warning(_ message: String, file: String = #file) {
        log(message, level: .warning, file: file)
    }

    public static func warning(_ message: String, tag: String?) {
        log(message, level: .warning, tag: tag)
    }

    public static func error(_ message: String, file: String = #file) {
        log(message, level: .error, file: file)
    }

    public static func error(_ message: String, tag: String?) {
        log(message, level: .error, tag: tag)
    }

    private static func log(_ message: String, level: Level, file: String = #file) {
        if let fileName = URL(fileURLWithPath: file).pathComponents.last,
           let tag = fileName.split(separator: ".").first
        {
            log(message, level: level, tag: String(tag).removingSuffix("ModuleImpl").removingSuffix("Impl"))
        } else {
            log(message, level: level, tag: file)
        }
    }

    private static func log(_ message: String, level: Level, tag: String?) {
        guard level != .debug || useAdvancedLogging else {
            return
        }

        let combined: String
        if let tag = tag, tag != "Notificare" {
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
}

extension NotificareLogger {
    enum Level: String {
        case debug
        case info
        case warning
        case error
    }
}

extension NotificareLogger.Level {
    func toOSLogType() -> OSLogType {
        switch self {
        case .debug, .info:
            return .default
        case .warning, .error:
            return .error
        }
    }
}
