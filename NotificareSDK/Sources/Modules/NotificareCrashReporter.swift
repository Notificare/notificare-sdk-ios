//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

struct NotificareCrashReporter {
    func configure() {
        let crashReportsEnabled = NotificareUtils.getConfiguration()?.crashReportsEnabled ?? true

        guard crashReportsEnabled else {
            Notificare.shared.logger.debug("Crash reports are not enabled.")
            return
        }

        // Catch NSExceptions
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)

        // Catch Swift exceptions
        signal(SIGQUIT, signalReceiver)
        signal(SIGILL, signalReceiver)
        signal(SIGTRAP, signalReceiver)
        signal(SIGABRT, signalReceiver)
        signal(SIGEMT, signalReceiver)
        signal(SIGFPE, signalReceiver)
        signal(SIGBUS, signalReceiver)
        signal(SIGSEGV, signalReceiver)
        signal(SIGSYS, signalReceiver)
        signal(SIGPIPE, signalReceiver)
        signal(SIGALRM, signalReceiver)
        signal(SIGXCPU, signalReceiver)
        signal(SIGXFSZ, signalReceiver)
    }

    func launch() {
        guard let event = NotificareUserDefaults.crashReport else {
            Notificare.shared.logger.debug("No crash report to process.")
            return
        }

        Notificare.shared.pushApi!.logEvent(event) { result in
            switch result {
            case .success:
                Notificare.shared.logger.info("Crash report processed.")

                // Clean up the stored crash report
                NotificareUserDefaults.crashReport = nil
            case let .failure(error):
                Notificare.shared.logger.error("Failed to process a crash report.")
                Notificare.shared.logger.debug("\(error)")
            }
        }
    }

    private let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)

        NotificareUserDefaults.crashReport = NotificareEvent(
            type: NotificareDefinitions.Events.applicationException,
            timestamp: timestamp,
            deviceId: Notificare.shared.deviceManager.currentDevice?.id,
            sessionId: Notificare.shared.sessionManager.sessionId,
            notificationId: nil,
            userId: Notificare.shared.deviceManager.currentDevice?.userId,
            data: [
                "platform": "iOS",
                "osVersion": NotificareUtils.osVersion,
                "deviceString": NotificareUtils.deviceString,
                "sdkVersion": NotificareDefinitions.sdkVersion,
                "appVersion": NotificareUtils.applicationVersion,
                "timestamp": timestamp,
                "name": exception.name.rawValue,
                "reason": exception.reason as Any,
                "stackSymbols": exception.callStackSymbols.joined(separator: "\n"),
            ]
        )
    }

    private let signalReceiver: @convention(c) (Int32) -> Void = { signal in
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let stackSymbols = Thread.callStackSymbols.joined(separator: "\n")
        let name: String

        switch signal {
        case SIGQUIT: name = "SIGQUIT"
        case SIGILL: name = "SIGILL"
        case SIGTRAP: name = "SIGTRAP"
        case SIGABRT: name = "SIGABRT"
        case SIGEMT: name = "SIGEMT"
        case SIGFPE: name = "SIGFPE"
        case SIGBUS: name = "SIGBUS"
        case SIGSEGV: name = "SIGSEGV"
        case SIGSYS: name = "SIGSYS"
        case SIGPIPE: name = "SIGPIPE"
        case SIGALRM: name = "SIGALRM"
        case SIGXCPU: name = "SIGXCPU"
        case SIGXFSZ: name = "SIGXFSZ"
        default: name = "Unknown"
        }

        NotificareUserDefaults.crashReport = NotificareEvent(
            type: NotificareDefinitions.Events.applicationException,
            timestamp: timestamp,
            deviceId: Notificare.shared.deviceManager.currentDevice?.id,
            sessionId: Notificare.shared.sessionManager.sessionId,
            notificationId: nil,
            userId: Notificare.shared.deviceManager.currentDevice?.userId,
            data: [
                "platform": "iOS",
                "osVersion": NotificareUtils.osVersion,
                "deviceString": NotificareUtils.deviceString,
                "sdkVersion": NotificareDefinitions.sdkVersion,
                "appVersion": NotificareUtils.applicationVersion,
                "timestamp": timestamp,
                "name": name,
                "reason": "Uncaught Signal \(name)",
                "stackSymbols": stackSymbols,
            ]
        )
    }
}
