//
// Copyright (c) 2024 Notificare. All rights reserved.
//

public enum NetworkUtils {
    public static func userAgent(sdkVersion: String) -> String {
        "\(ApplicationUtils.applicationName)/\(ApplicationUtils.applicationVersion) Notificare/\(sdkVersion) iOS/\(DeviceUtils.osVersion)"
    }
}
