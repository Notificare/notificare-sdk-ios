//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit

private let KEY_CREDENTIALS = "re.notifica.authentication.credentials"

internal enum LocalStorage {
    private static let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    static var credentials: Credentials? {
        get {
            do {
                let data = try keychain.get(account: KEY_CREDENTIALS)
                return try NotificareUtils.jsonDecoder.decode(Credentials.self, from: data)
            } catch {
                NotificareLogger.warning("Failed to decode the stored credentials.\n\(error)")
                return nil
            }
        }
        set {
            if let credentials = newValue {
                do {
                    let encoded = try NotificareUtils.jsonEncoder.encode(credentials)

                    try keychain.contains(account: KEY_CREDENTIALS)
                        ? try keychain.update(encoded, account: KEY_CREDENTIALS)
                        : try keychain.add(encoded, account: KEY_CREDENTIALS)
                } catch {
                    NotificareLogger.warning("Failed to store the credentials.")
                }
            } else {
                do {
                    try keychain.remove(account: KEY_CREDENTIALS)
                } catch {
                    NotificareLogger.warning("Failed to remove the stored credentials.")
                }
            }
        }
    }
}
