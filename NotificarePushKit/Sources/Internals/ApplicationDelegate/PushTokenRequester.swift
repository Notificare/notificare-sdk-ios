//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import UIKit
import NotificareKit

@MainActor
internal final class PushTokenRequester {
    private var waiters: [CheckedContinuation<String, Error>] = []
    private var isWaitingForOSResponse = false

    internal nonisolated init() {}

    internal func requestToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            waiters.append(continuation)

            if !isWaitingForOSResponse {
                isWaitingForOSResponse = true

                logger.debug("Registering for remote notifications with the operative system.")
                UIApplication.shared.registerForRemoteNotifications()

//                // Simulate OS response after a small random delay.
//                Task { @MainActor in
//                    try? await Task.sleep(nanoseconds: UInt64.random(in: 0...5) * 1_000_000)
//                    signalTokenReceived(Data([0xde, 0xad, 0xbe, 0xef]))
//                }
            }
        }
    }

    internal func signalTokenReceived(_ token: Data) {
        logger.debug("Received an APNS token to continue.")
        resume(with: .success(token.toHexString()))
    }

    internal func signalTokenRequestError(_ error: Error) {
        logger.debug("Received an APNS error to continue.")
        resume(with: .failure(error))
    }

    private func resume(with result: Result<String, Error>) {
        guard isWaitingForOSResponse else {
            logger.warning("APNS result received but no request is in flight.")
            return
        }

        isWaitingForOSResponse = false

        let continuations = waiters
        waiters.removeAll()

        logger.debug("Resuming \(continuations.count) APNS token requests.")

        for continuation in continuations {
            continuation.resume(with: result)
        }
    }
}
