//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

internal class NotificareCrashReporterModuleImpl: NSObject, NotificareModule {
    internal static let instance = NotificareCrashReporterModuleImpl()

    // MARK: - Notificare Module

    static func configure() {
        let crashReportsEnabled = Notificare.shared.options!.crashReportsEnabled

        guard crashReportsEnabled else {
            NotificareLogger.debug("Crash reports are not enabled.")
            return
        }

        // Catch NSExceptions
        NSSetUncaughtExceptionHandler(instance.uncaughtExceptionHandler)

        // Catch Swift exceptions
        signal(SIGQUIT, instance.signalReceiver)
        signal(SIGILL, instance.signalReceiver)
        signal(SIGTRAP, instance.signalReceiver)
        signal(SIGABRT, instance.signalReceiver)
        signal(SIGEMT, instance.signalReceiver)
        signal(SIGFPE, instance.signalReceiver)
        signal(SIGBUS, instance.signalReceiver)
        signal(SIGSEGV, instance.signalReceiver)
        signal(SIGSYS, instance.signalReceiver)
        signal(SIGPIPE, instance.signalReceiver)
        signal(SIGALRM, instance.signalReceiver)
        signal(SIGXCPU, instance.signalReceiver)
        signal(SIGXFSZ, instance.signalReceiver)
    }

    static func launch(_ completion: @escaping NotificareCallback<Void>) {
        guard let event = LocalStorage.crashReport else {
            NotificareLogger.debug("No crash report to process.")
            completion(.success(()))
            return
        }

        NotificareRequest.Builder()
            .post("/event", body: event)
            .response { result in
                switch result {
                case .success:
                    NotificareLogger.info("Crash report processed.")

                    // Clean up the stored crash report
                    LocalStorage.crashReport = nil
                case let .failure(error):
                    NotificareLogger.error("Failed to process a crash report.")
                    NotificareLogger.debug("\(error)")
                }
            }

        completion(.success(()))
    }

    // MARK: - Internal API

    private let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)

        LocalStorage.crashReport = NotificareEvent(
            type: NotificareDefinitions.Events.applicationException,
            timestamp: timestamp,
            deviceId: Notificare.shared.device().currentDevice?.id,
            sessionId: Notificare.shared.session().sessionId,
            notificationId: nil,
            userId: Notificare.shared.device().currentDevice?.userId,
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

        LocalStorage.crashReport = NotificareEvent(
            type: NotificareDefinitions.Events.applicationException,
            timestamp: timestamp,
            deviceId: Notificare.shared.device().currentDevice?.id,
            sessionId: Notificare.shared.session().sessionId,
            notificationId: nil,
            userId: Notificare.shared.device().currentDevice?.userId,
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
