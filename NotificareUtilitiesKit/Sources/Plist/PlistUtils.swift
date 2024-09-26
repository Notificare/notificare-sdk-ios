//
// Copyright (c) 2024 Notificare. All rights reserved.
//

public enum PlistUtils {
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
