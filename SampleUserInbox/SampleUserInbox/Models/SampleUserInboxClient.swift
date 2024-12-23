//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation
import OSLog

internal struct SampleUserInboxClient: Decodable {
    internal let fetchInboxUrl: String
    internal let registerDeviceUrl: String

    var isAllDataFilled: Bool {
        return !fetchInboxUrl.isEmpty &&
               !registerDeviceUrl.isEmpty
    }
}

extension SampleUserInboxClient {
    internal static func loadFromPlist() -> SampleUserInboxClient? {
        guard let path = Bundle.main.path(forResource: "SampleUserInboxClient", ofType: "plist") else {
            Logger.main.info("SampleUserInboxClient.plist not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let decoder = PropertyListDecoder()
            return try decoder.decode(SampleUserInboxClient.self, from: data)
        } catch {
            Logger.main.error("Failed to decode SampleUser.plist: \(error)")
            return nil
        }
    }
}
