//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import NotificareUtilitiesKit

internal class NotificareCrashReporterModuleImpl: NSObject, NotificareModule {
    // MARK: - Notificare Module

    internal static let instance = NotificareCrashReporterModuleImpl()

    internal func configure() {
        let crashReportsEnabled = Notificare.shared.options!.crashReportsEnabled

        guard crashReportsEnabled else {
            logger.debug("Crash reports are not enabled.")
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

    internal func launch() async throws {
        guard let event = LocalStorage.crashReport else {
            logger.debug("No crash report to process.")
            return
        }

        do {
            try await NotificareRequest.Builder()
                .post("/event", body: event)
                .response()

            logger.info("Crash report processed.")

            // Clean up the stored crash report
            LocalStorage.crashReport = nil
        } catch {
            logger.error("Failed to process a crash report.", error: error)

        }
    }

    // MARK: - Internal API

    private let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process a crash report before the device becomes available.")
            return
        }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)

        LocalStorage.crashReport = NotificareEvent(
            type: "re.notifica.event.application.Exception",
            timestamp: timestamp,
            deviceId: device.id,
            sessionId: Notificare.shared.session().sessionId,
            notificationId: nil,
            userId: device.userId,
            data: [
                "platform": "iOS",
                "osVersion": DeviceUtils.osVersion,
                "deviceString": DeviceUtils.deviceString,
                "sdkVersion": Notificare.SDK_VERSION,
                "appVersion": ApplicationUtils.applicationVersion,
                "timestamp": timestamp,
                "name": exception.name.rawValue,
                "reason": exception.reason as Any,
                "stackSymbols": exception.callStackSymbols.joined(separator: "\n"),
            ]
        )
    }

    private let signalReceiver: @convention(c) (Int32) -> Void = { signal in
        guard let device = Notificare.shared.device().currentDevice else {
            logger.warning("Cannot process a crash report before the device becomes available.")
            return
        }

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
            type: "re.notifica.event.application.Exception",
            timestamp: timestamp,
            deviceId: device.id,
            sessionId: Notificare.shared.session().sessionId,
            notificationId: nil,
            userId: device.userId,
            data: [
                "platform": "iOS",
                "osVersion": DeviceUtils.osVersion,
                "deviceString": DeviceUtils.deviceString,
                "sdkVersion": Notificare.SDK_VERSION,
                "appVersion": ApplicationUtils.applicationVersion,
                "timestamp": timestamp,
                "name": name,
                "reason": "Uncaught Signal \(name)",
                "stackSymbols": stackSymbols,
            ]
        )
    }
}
