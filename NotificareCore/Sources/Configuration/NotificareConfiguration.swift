//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import UIKit

public struct NotificareConfiguration: Codable {
    public let autoLaunch: Bool
    public let swizzlingEnabled: Bool
    public let crashReportsEnabled: Bool
    public let services: String?
    public let production: Bool
    public let developmentApplicationKey: String?
    public let developmentApplicationSecret: String?
    public let productionApplicationKey: String?
    public let productionApplicationSecret: String?
    public let options: Options?
}

public extension NotificareConfiguration {
    struct Options: Codable {
        public let urlSchemes: [String]?
        public let closeWindowQueryParameter: String?
        public let imageSharing: Bool?
        public let themes: Themes?
    }
}

public extension NotificareConfiguration.Options {
    struct Themes: Codable {
        public let light: NotificareConfiguration.Theme?
        public let dark: NotificareConfiguration.Theme?
    }
}

public extension NotificareConfiguration {
    struct Theme: Codable {
        public let backgroundColor: String?
        public let actionButtonTextColor: String?
        public let toolbarBackgroundColor: String?
        public let activityIndicatorColor: String?
        public let buttonTextColor: String?
        public let textFieldTextColor: String?
        public let textFieldBackgroundColor: String?
    }
}

public extension NotificareConfiguration {
    func theme(for controller: UIViewController) -> NotificareConfiguration.Theme? {
        var theme = options?.themes?.light

        if #available(iOS 13.0, *) {
            if controller.overrideUserInterfaceStyle == .dark, let darkTheme = self.options?.themes?.dark {
                theme = darkTheme
            }
        }

        return theme
    }
}
