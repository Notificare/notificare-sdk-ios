//
// Copyright (c) 2024 Notificare. All rights reserved.
//

import UIKit

extension UIDevice {
    public func userAgent(bundle: Bundle = Bundle.main, sdkVersion: String) -> String {
        let appName = bundle.applicationName
        let appVersion = bundle.applicationVersion
        let osVersion = UIDevice.current.systemVersion

        return "\(appName)/\(appVersion) Notificare/\(sdkVersion) iOS/\(osVersion)"
    }
}
