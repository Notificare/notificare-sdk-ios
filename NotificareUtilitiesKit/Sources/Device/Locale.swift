//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import Foundation

extension Locale {
    public func deviceLanguage(preferredLanguages: [String] = NSLocale.preferredLanguages) -> String {
        var language = "en"
        if !preferredLanguages.isEmpty {
            let preferredLanguage = preferredLanguages[0]
            let comps = preferredLanguage.components(separatedBy: "-")
            if !comps.isEmpty {
                language = comps[0]
            }
        }
        return language
    }

    public func deviceRegion(preferredLanguages: [String] = NSLocale.preferredLanguages) -> String {
        var region = "US"
        if !preferredLanguages.isEmpty {
            let preferredLanguage = preferredLanguages[0]
            let comps = preferredLanguage.components(separatedBy: "-")
            if comps.count > 1 {
                region = comps[1]
            }
        }
        return region
    }
}
