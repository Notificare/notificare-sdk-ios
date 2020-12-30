//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

struct NotificareUtils {
    private init() {}

    static var applicationName: String? {
        if let bundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return bundleDisplayName
        } else if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return bundleName
        }

        return ""
    }

    static var applicationVersion: String {
        if let bundleShortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleShortVersion
        } else if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleVersion
        }

        return "1.0.0"
    }

    static var deviceString: String {
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

    static var deviceLanguage: String {
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

    static var deviceRegion: String {
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

    static var osVersion: String {
        UIDevice.current.systemVersion
    }

    static var timeZoneOffset: Float {
        Float(TimeZone.current.secondsFromGMT()) / 3600.0
    }

    static func getConfiguration() -> NotificareConfiguration? {
        guard let path = Bundle.main.path(forResource: "Notificare", ofType: "plist") else {
            fatalError("Notificare.plist is missing.")
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Notificare.plist data appears to be corrupted.")
        }

        let decoder = PropertyListDecoder()
        guard let configuration = try? decoder.decode(NotificareConfiguration.self, from: data) else {
            fatalError("Failed to parse Notificare.plist. Please check the contents are valid.")
        }

        return configuration
    }

    static func getLoadedModules() -> [String] {
        let modules = [String]()

//        if Notificare.shared.pushManager != nil {
//            modules.append("push")
//        }
//
//        if Notificare.shared.locationManager != nil {
//            modules.append("location")
//        }

        return modules
    }

    static func logCapabilities() {}

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(identifier: "UTC")

        return formatter
    }()

    static func createJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return decoder
    }

    static func createJsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        return encoder
    }
}
