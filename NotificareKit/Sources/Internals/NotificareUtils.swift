//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public enum NotificareUtils {
    public static var applicationName: String? {
        if let bundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }

        return ""
    }

    public static var applicationVersion: String {
        if let bundleShortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleShortVersion
        } else if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleVersion
        }

        return "1.0.0"
    }

    public static var deviceString: String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }

            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }

    public static var deviceLanguage: String {
        var language = "en"

        if !NSLocale.preferredLanguages.isEmpty {
            let preferredLanguage = NSLocale.preferredLanguages[0]
            let comps = preferredLanguage.components(separatedBy: "-")
            if !comps.isEmpty {
                language = comps[0]
            }
        }

        return language
    }

    public static var deviceRegion: String {
        var region = "US"

        if !NSLocale.preferredLanguages.isEmpty {
            let preferredLanguage = NSLocale.preferredLanguages[0]
            let comps = preferredLanguage.components(separatedBy: "-")
            if comps.count > 1 {
                region = comps[1]
            }
        }

        return region
    }

    public static var osVersion: String {
        UIDevice.current.systemVersion
    }

    public static var timeZoneOffset: Float {
        Float(TimeZone.current.secondsFromGMT()) / 3600.0
    }

    // MARK: - Modules

    public static func getLoadedModules() -> [String] {
        var modules = [String]()

        NotificareDefinitions.Modules.allCases.forEach { module in
            if module.isAvailable {
                modules.append("\(module)")
            }
        }

        return modules
    }

    // MARK: - JSON encoding

    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(NotificareIsoDateUtils.parser)

        return decoder
    }()

    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(NotificareIsoDateUtils.formatter)

        return encoder
    }()

    // MARK: - Plist

    public static func getSupportedUrlSchemes() -> [String] {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            return []
        }

        var supportedUrlSchemes: [String] = []

        urlTypes.forEach { item in
            if let urlSchemes = item["CFBundleURLSchemes"] as? [String] {
                supportedUrlSchemes += urlSchemes
            }
        }

        return supportedUrlSchemes
    }
}
