//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public struct NotificareServicesInfo: Decodable {
    internal static let fileName = "NotificareServices"
    internal static let fileExtension = "plist"

    public let applicationKey: String
    public let applicationSecret: String
    internal let services: Services

    public init(applicationKey: String, applicationSecret: String) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        services = .production
    }

    public init?(contentsOfFile plistPath: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))

            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(NotificareServicesInfo.self, from: data)

            applicationKey = decoded.applicationKey
            applicationSecret = decoded.applicationSecret
            services = decoded.services
        } catch {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        applicationKey = try container.decode(String.self, forKey: .applicationKey)
        applicationSecret = try container.decode(String.self, forKey: .applicationSecret)

        let useTestApi = container.contains(.useTestApi)
            ? try container.decode(Bool.self, forKey: .useTestApi)
            : false

        services = useTestApi ? .test : .production
    }

    enum CodingKeys: String, CodingKey {
        case applicationKey = "APPLICATION_KEY"
        case applicationSecret = "APPLICATION_SECRET"
        case useTestApi = "USE_TEST_API"
    }

    internal enum Services {
        case test
        case production

        public var pushHost: String {
            switch self {
            case .test: return "https://push-test.notifica.re"
            case .production: return "https://push.notifica.re"
            }
        }

        public var cloudHost: String {
            switch self {
            case .test: return "https://cloud-test.notifica.re"
            case .production: return "https://cloud.notifica.re"
            }
        }

        public var webPassHost: String {
            switch self {
            case .test: return "https://pass-test.notifica.re"
            case .production: return "https://pass.notifica.re"
            }
        }

        public var dynamicLinksDomain: String {
            switch self {
            case .test: return "test.ntc.re"
            case .production: return "ntc.re"
            }
        }
    }
}
