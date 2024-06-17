//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import UIKit
import NotificareKit

internal class PushTokenRequester {

    private var task: Task<String, Error>?
    private var continuation: CheckedContinuation<String, Error>?
    private let semaphore = DispatchSemaphore(value: 1)

    internal func requestToken() async throws -> String {
        let task = upsertTokenTask()
        let token = try await task.value

        self.task = nil
        self.continuation = nil

        return token
    }

    internal func signalTokenReceived(_ token: Data) {
        guard let continuation else {
            NotificareLogger.warning("Received an APNS token without a continuation available.")
            return
        }

        NotificareLogger.debug("Received an APNS token to continue.")
        continuation.resume(returning: token.toHexString())
    }

    internal func signalTokenRequestError(_ error: Error) {
        guard let continuation else {
            NotificareLogger.warning("Received an APNS token error without a continuation available.")
            return
        }

        NotificareLogger.debug("Received an APNS error to continue.")
        continuation.resume(throwing: error)
    }

    private func upsertTokenTask() -> Task<String, Error> {
        semaphore.wait()

        defer {
            semaphore.signal()
        }

        if let task {
            NotificareLogger.debug("Reusing pending APNS token task.")
            return task
        }

        NotificareLogger.debug("Creating a new APNS token task.")

        let task = Task {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation

                DispatchQueue.main.async {
                    NotificareLogger.debug("Registering for remote notifications with the operative system.")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        self.task = task

        return task
    }
}
