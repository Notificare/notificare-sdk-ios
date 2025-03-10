//
// Copyright (c) 2025 Notificare. All rights reserved.
//

import Foundation
import CoreData

@available(iOS, obsoleted: 15.0, message: "Use Core Data's native async function 'perform'.")
extension NSManagedObjectContext {
    public func performCompat<T>(_ block: @escaping () throws -> T) async throws -> T {
        if #available(iOS 15.0, *) {
            return try await perform(block)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                performAndWait {
                    do {
                        let result = try block()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    public func performCompat<T>(_ block: @escaping () -> T) async -> T {
        if #available(iOS 15.0, *) {
            return await perform(block)
        } else {
            return await withCheckedContinuation { continuation in
                performAndWait {
                    let result = block()
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
