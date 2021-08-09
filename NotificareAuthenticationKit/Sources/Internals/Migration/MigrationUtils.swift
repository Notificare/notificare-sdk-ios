//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import Security

struct MigrationUtils {
    private static let service = "\(Bundle.main.bundleIdentifier!)::NXOAuth2AccountStore"

    static func getLegacyCredentials() -> NotificareNXOAuth2Account? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword as AnyObject,
            kSecAttrService as String: service as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue as AnyObject,
        ]

        // SecItemCopyMatching will attempt to copy the item
        // identified by query to the reference itemCopy
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        // errSecItemNotFound is a special status indicating the
        // read item does not exist. Throw itemNotFound so the
        // client can determine whether or not to handle
        // this case
        guard status != errSecItemNotFound else {
            // throw KeychainError.itemNotFound
            return nil
        }

        // Any status other than errSecSuccess indicates the
        // read operation failed.
        guard status == errSecSuccess else {
            // throw KeychainError.unexpectedStatus(status)
            return nil
        }

        // This implementation of KeychainInterface requires all
        // items to be saved and read as Data. Otherwise,
        // invalidItemFormat is thrown
        guard let attributes = itemCopy as? [String: AnyObject] else {
            // throw KeychainError.invalidItemFormat
            return nil
        }

        guard let data = attributes[kSecAttrGeneric as String] as? Data else {
            return nil
        }

        NSKeyedUnarchiver.setClass(NotificareNXOAuth2Account.self, forClassName: "NotificareNXOAuth2Account")
        NSKeyedUnarchiver.setClass(NotificareNXOAuth2AccessToken.self, forClassName: "NotificareNXOAuth2AccessToken")

        guard let accounts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: NotificareNXOAuth2Account] else {
            return nil
        }

        return accounts
            .values
            .first { $0.accountType == "Notificare_\(Notificare.shared.servicesInfo!.applicationKey)" }
    }

    static func removeLegacyCredentials() {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
        ]

        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)

        // Any status other than errSecSuccess indicates the
        // delete operation failed.
        guard status == errSecSuccess else {
            // throw KeychainError.unexpectedStatus(status)
            return
        }
    }
}
