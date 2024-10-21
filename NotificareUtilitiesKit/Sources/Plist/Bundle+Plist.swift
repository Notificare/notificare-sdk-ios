//
// Copyright (c) 2024 Notificare. All rights reserved.
//

extension Bundle {
    public func getSupportedUrlSchemes() -> [String] {
        guard let urlTypes = object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
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
