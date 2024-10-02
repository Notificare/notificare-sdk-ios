//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import OSLog

internal struct SampleUser: Decodable {
    internal let userName: String
    internal let userId: String
}

extension SampleUser {
    internal static func loadFromPlist() -> SampleUser? {
        guard let path = Bundle.main.path(forResource: "SampleUser", ofType: "plist") else {
            Logger.main.info("SampleUser.plist not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let decoder = PropertyListDecoder()
            return try decoder.decode(SampleUser.self, from: data)
        } catch {
            Logger.main.error("Failed to decode SampleUser.plist: \(error)")
            return nil
        }
    }
}
