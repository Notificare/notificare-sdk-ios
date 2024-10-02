//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

private let DEFAULT_REST_API_HOST = "push.notifica.re"
private let DEFAULT_SHORT_LINKS_HOST = "ntc.re"
private let DEFAULT_APP_LINKS_HOST = "applinks.notifica.re"

private let HOST_REGEX = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])$".toRegex()

public struct NotificareServicesInfo: Decodable {
    internal static let fileName = "NotificareServices"
    internal static let fileExtension = "plist"

    public let applicationKey: String
    public let applicationSecret: String
    public let hosts: Hosts

    public init(applicationKey: String, applicationSecret: String, hosts: Hosts = Hosts()) {
        self.applicationKey = applicationKey
        self.applicationSecret = applicationSecret
        self.hosts = hosts
    }

    public init?(contentsOfFile plistPath: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))

            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(NotificareServicesInfo.self, from: data)

            applicationKey = decoded.applicationKey
            applicationSecret = decoded.applicationSecret
            hosts = decoded.hosts
        } catch {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        applicationKey = try container.decode(String.self, forKey: .applicationKey)
        applicationSecret = try container.decode(String.self, forKey: .applicationSecret)
        hosts = try container.decodeIfPresent(Hosts.self, forKey: .hosts) ?? Hosts()
    }

    private enum CodingKeys: String, CodingKey {
        case applicationKey = "APPLICATION_KEY"
        case applicationSecret = "APPLICATION_SECRET"
        case hosts = "HOSTS"
    }

    public struct Hosts: Decodable {
        public let restApi: String
        public let appLinks: String
        public let shortLinks: String

        public init() {
            self.restApi = DEFAULT_REST_API_HOST
            self.appLinks = DEFAULT_APP_LINKS_HOST
            self.shortLinks = DEFAULT_SHORT_LINKS_HOST
        }

        public init(restApi: String, appLinks: String, shortLinks: String) {
            self.restApi = restApi
            self.appLinks = appLinks
            self.shortLinks = shortLinks
        }

        private enum CodingKeys: String, CodingKey {
            case restApi = "REST_API"
            case appLinks = "APP_LINKS"
            case shortLinks = "SHORT_LINKS"
        }
    }
}

extension NotificareServicesInfo {
    internal var hasDefaultHosts: Bool {
        hosts.restApi == DEFAULT_REST_API_HOST && hosts.appLinks == DEFAULT_APP_LINKS_HOST && hosts.shortLinks == DEFAULT_SHORT_LINKS_HOST
    }

    internal func validate() throws {
        guard hosts.restApi.matches(HOST_REGEX) else {
            logger.warning("Invalid REST API host.")
            throw ValidationError.invalidHost
        }

        guard hosts.appLinks.matches(HOST_REGEX) else {
            logger.warning("Invalid AppLinks host.")
            throw ValidationError.invalidHost
        }

        guard hosts.shortLinks.matches(HOST_REGEX) else {
            logger.warning("Invalid short links host.")
            throw ValidationError.invalidHost
        }
    }

    internal enum ValidationError: Error {
        case invalidHost
    }
}
