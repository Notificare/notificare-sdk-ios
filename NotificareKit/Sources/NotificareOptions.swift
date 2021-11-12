//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public struct NotificareOptions {
    internal static let fileName = "NotificareOptions"
    internal static let fileExtension = "plist"

    public let debugLoggingEnabled: Bool
    public let autoConfig: Bool
    public let swizzlingEnabled: Bool
    public let userNotificationCenterDelegateEnabled: Bool
    public let crashReportsEnabled: Bool
    public let headingApiEnabled: Bool
    public let visitsApiEnabled: Bool
    public let urlSchemes: [String]
    public let closeWindowQueryParameter: String?
    public let imageSharingEnabled: Bool
    public let safariDismissButtonStyle: Int?
    public let themes: Themes?

    public struct Themes: Decodable {
        public let light: NotificareOptions.Theme?
        public let dark: NotificareOptions.Theme?
    }

    public struct Theme: Decodable {
        public let backgroundColor: String?
        public let actionButtonTextColor: String?
        public let toolbarBackgroundColor: String?
        public let activityIndicatorColor: String?
        public let buttonTextColor: String?
        public let textFieldTextColor: String?
        public let textFieldBackgroundColor: String?
        public let safariBarTintColor: String?
        public let safariControlsTintColor: String?
    }
}

extension NotificareOptions: Decodable {
    public init() {
        self.init(
            debugLoggingEnabled: false,
            autoConfig: true,
            swizzlingEnabled: true,
            userNotificationCenterDelegateEnabled: true,
            crashReportsEnabled: true,
            headingApiEnabled: false,
            visitsApiEnabled: false,
            urlSchemes: [],
            closeWindowQueryParameter: nil,
            imageSharingEnabled: true,
            safariDismissButtonStyle: nil,
            themes: nil
        )
    }

    public init?(contentsOfFile plistPath: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))

            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(NotificareOptions.self, from: data)

            debugLoggingEnabled = decoded.debugLoggingEnabled
            autoConfig = decoded.autoConfig
            swizzlingEnabled = decoded.swizzlingEnabled
            userNotificationCenterDelegateEnabled = decoded.userNotificationCenterDelegateEnabled
            crashReportsEnabled = decoded.crashReportsEnabled
            headingApiEnabled = decoded.headingApiEnabled
            visitsApiEnabled = decoded.visitsApiEnabled
            urlSchemes = decoded.urlSchemes
            closeWindowQueryParameter = decoded.closeWindowQueryParameter
            imageSharingEnabled = decoded.imageSharingEnabled
            safariDismissButtonStyle = decoded.safariDismissButtonStyle
            themes = decoded.themes
        } catch {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        debugLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugLoggingEnabled) ?? false
        autoConfig = try container.decodeIfPresent(Bool.self, forKey: .autoConfig) ?? true
        swizzlingEnabled = try container.decodeIfPresent(Bool.self, forKey: .swizzlingEnabled) ?? true
        userNotificationCenterDelegateEnabled = try container.decodeIfPresent(Bool.self, forKey: .userNotificationCenterDelegateEnabled) ?? true
        crashReportsEnabled = try container.decodeIfPresent(Bool.self, forKey: .crashReportsEnabled) ?? true
        headingApiEnabled = try container.decodeIfPresent(Bool.self, forKey: .headingApiEnabled) ?? false
        visitsApiEnabled = try container.decodeIfPresent(Bool.self, forKey: .visitsApiEnabled) ?? false
        urlSchemes = try container.decodeIfPresent([String].self, forKey: .urlSchemes) ?? []
        closeWindowQueryParameter = try container.decodeIfPresent(String.self, forKey: .closeWindowQueryParameter)
        imageSharingEnabled = try container.decodeIfPresent(Bool.self, forKey: .imageSharingEnabled) ?? true
        safariDismissButtonStyle = try container.decodeIfPresent(Int.self, forKey: .safariDismissButtonStyle)
        themes = try container.decodeIfPresent(Themes.self, forKey: .themes)
    }

    enum CodingKeys: String, CodingKey {
        case debugLoggingEnabled = "DEBUG_LOGGING_ENABLED"
        case autoConfig = "AUTO_CONFIG"
        case swizzlingEnabled = "SWIZZLING_ENABLED"
        case userNotificationCenterDelegateEnabled = "USER_NOTIFICATION_CENTER_DELEGATE_ENABLED"
        case crashReportsEnabled = "CRASH_REPORTING_ENABLED"
        case headingApiEnabled = "HEADING_API_ENABLED"
        case visitsApiEnabled = "VISITS_API_ENABLED"
        case urlSchemes = "URL_SCHEMES"
        case closeWindowQueryParameter = "CLOSE_WINDOW_QUERY_PARAMETER"
        case imageSharingEnabled = "IMAGE_SHARING_ENABLED"
        case safariDismissButtonStyle = "SAFARI_DISMISS_BUTTON_STYLE"
        case themes = "THEMES"
    }
}

public extension NotificareOptions {
    func theme(for controller: UIViewController) -> NotificareOptions.Theme? {
        var theme = themes?.light

        if #available(iOS 13.0, *) {
            if controller.overrideUserInterfaceStyle == .dark, let darkTheme = self.themes?.dark {
                theme = darkTheme
            }
        }

        return theme
    }
}
