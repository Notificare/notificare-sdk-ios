//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareServicesInfo: Decodable {
    internal static let fileName = "NotificareServices"
    internal static let fileExtension = "plist"

    public let applicationKey: String
    public let applicationSecret: String
    public let useTestApi: Bool

    public init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        useTestApi = false
    }

    public init?(contentsOfFile plistPath: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))

            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(NotificareServicesInfo.self, from: data)

            applicationKey = decoded.applicationKey
            applicationSecret = decoded.applicationSecret
            useTestApi = decoded.useTestApi
        } catch {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        applicationKey = try container.decode(String.self, forKey: .applicationKey)
        applicationSecret = try container.decode(String.self, forKey: .applicationSecret)

        if container.contains(.useTestApi) {
            useTestApi = try container.decode(Bool.self, forKey: .useTestApi)
        } else {
            useTestApi = false
        }
    }

    enum CodingKeys: String, CodingKey {
        case applicationKey = "APPLICATION_KEY"
        case applicationSecret = "APPLICATION_SECRET"
        case useTestApi = "USE_TEST_API"
    }
}
