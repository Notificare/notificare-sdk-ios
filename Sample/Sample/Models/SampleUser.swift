//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

public struct SampleUser: Decodable {
    internal static let fileName = "SampleUser"
    internal static let fileExtension = "plist"

    public let userName: String
    public let userID: String

    public init?(contentsOfFile plistPath: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))

            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(SampleUser.self, from: data)

            userName = decoded.userName
            userID = decoded.userID
        } catch {
            return nil
        }

    }
}
