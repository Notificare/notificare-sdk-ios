//
//  NotificareLogger.swift
//  Core
//
//  Created by Helder Pinhal on 13/07/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import os

public class NotificareLogger {

    @available(iOS 14.0, *)
    private lazy var logger = Logger(subsystem: "re.notifica", category: "Notificare")

    private let osLog = OSLog(subsystem: "re.notifica", category: "Notificare")


    public var level: Level = .info


    public func verbose(_ message: String) {
        self.log(message, level: .verbose)
    }

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

        if #available(iOS 14, *) {
            self.logger.log(level: level.toOSLogType(), "\(message, privacy: .public)")
        } else {
            os_log(level.toOSLogType(), log: self.osLog, "%{public}s", message)
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

    public static func <(lhs: NotificareLogger.Level, rhs: NotificareLogger.Level) -> Bool {
        return lhs.severity < rhs.severity
    }
}

extension NotificareLogger.Level {
    func toOSLogType() -> OSLogType {
        switch self {
        case .verbose, .debug:
            return .debug
        case .info:
            return .info
        case .warning, .error:
            return .error
        }
    }
}
