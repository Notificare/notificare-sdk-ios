//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import os

public struct NotificareLogger {

    public init(subsystem: String = "re.notifica", category: String = "Notificare") {
        self.osLog = OSLog(subsystem: subsystem, category: category)

        if #available(iOS 14, *) {
            self.logger = Logger(subsystem: subsystem, category: category)
        }
    }

    public var hasDebugLoggingEnabled: Bool = false
    public var labelIgnoreList: [String] = Array()

    private let osLog: OSLog
    private var logger: Any?

    public func debug(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .debug, message: message, error: error, file: file)
    }

    public func info(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .info, message: message, error: error, file: file)
    }

    public func warning(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .warning, message: message, error: error, file: file)
    }

    public func error(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .error, message: message, error: error, file: file)
    }

    private func log(level: Level, message: String, error: Error?, file: String = #file) {
        let label: String

        if
            let fullFileName = URL(fileURLWithPath: file).pathComponents.last,
            let fileName = fullFileName.split(separator: ".").first
        {
            label = String(fileName).removingSuffix("ModuleImpl").removingSuffix("Impl")
        } else {
            label = file
        }

        log(level: level, label: label, message: message, error: error)
    }

    private func log(level: Level, label: String?, message: String, error: Error?) {
        guard level != .debug || hasDebugLoggingEnabled else {
            return
        }

        var combined: String
        if let label = label, !labelIgnoreList.contains(label), hasDebugLoggingEnabled {
            combined = "[\(label)] \(message)"
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
            if let logger = self.logger as? Logger {
                logger.log(level: level.toOSLogType(), "\(combined, privacy: .public)")
            }
        } else {
            os_log("%{public}s", log: osLog, type: level.toOSLogType(), combined)
        }
    }
}

extension NotificareLogger {
    internal enum Level: String {
        case debug
        case info
        case warning
        case error
    }
}

extension NotificareLogger.Level {
    internal func toOSLogType() -> OSLogType {
        switch self {
        case .debug, .info:
            return .default
        case .warning, .error:
            return .error
        }
    }
}
