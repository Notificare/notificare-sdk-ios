//
// Copyright (c) 2024 Notificare. All rights reserved.
//
import UIKit

public enum DeviceUtils {
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
}
