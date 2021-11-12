//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import os

public enum NotificareLogger {
    @available(iOS 14.0, *)
    private static var logger = Logger(subsystem: "re.notifica", category: "Notificare")

    private static let osLog = OSLog(subsystem: "re.notifica", category: "Notificare")

    private static var hasDebugLoggingEnabled: Bool {
        Notificare.shared.options?.debugLoggingEnabled ?? false
    }

    public static func debug(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .debug, message: message, error: error, file: file)
    }

    public static func info(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .info, message: message, error: error, file: file)
    }

    public static func warning(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .warning, message: message, error: error, file: file)
    }

    public static func error(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .error, message: message, error: error, file: file)
    }

    private static func log(level: Level, message: String, error: Error?, file: String = #file) {
        let tag: String

        if let fullFileName = URL(fileURLWithPath: file).pathComponents.last,
           let fileName = fullFileName.split(separator: ".").first
        {
            tag = String(fileName).removingSuffix("ModuleImpl").removingSuffix("Impl")
        } else {
            tag = file
        }

        log(level: level, tag: tag, message: message, error: error)
    }

    private static func log(level: Level, tag: String?, message: String, error: Error?) {
        guard level != .debug || hasDebugLoggingEnabled else {
            return
        }

        var combined: String
        if let tag = tag, tag != "Notificare", hasDebugLoggingEnabled {
            combined = "[\(tag)] \(message)"
        } else {
            combined = message
        }

        if let error = error {
            if hasDebugLoggingEnabled {
                combined = "\(combined)\n\(error)"
            } else {
                combined = "\(combined) \(error.localizedDescription)"
            }
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
