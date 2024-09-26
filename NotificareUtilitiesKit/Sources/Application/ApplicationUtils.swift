//
// Copyright (c) 2024 Notificare. All rights reserved.
//

public enum ApplicationUtils {
    public static var applicationName: String {
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
}
