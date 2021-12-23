//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public struct NotificareOptions: Decodable {
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

    public init(debugLoggingEnabled: Bool, autoConfig: Bool, swizzlingEnabled: Bool, userNotificationCenterDelegateEnabled: Bool, crashReportsEnabled: Bool, headingApiEnabled: Bool, visitsApiEnabled: Bool, urlSchemes: [String], closeWindowQueryParameter: String?, imageSharingEnabled: Bool, safariDismissButtonStyle: Int?, themes: NotificareOptions.Themes?) {
        self.debugLoggingEnabled = debugLoggingEnabled
        self.autoConfig = autoConfig
        self.swizzlingEnabled = swizzlingEnabled
        self.userNotificationCenterDelegateEnabled = userNotificationCenterDelegateEnabled
        self.crashReportsEnabled = crashReportsEnabled
        self.headingApiEnabled = headingApiEnabled
        self.visitsApiEnabled = visitsApiEnabled
        self.urlSchemes = urlSchemes
        self.closeWindowQueryParameter = closeWindowQueryParameter
        self.imageSharingEnabled = imageSharingEnabled
        self.safariDismissButtonStyle = safariDismissButtonStyle
        self.themes = themes
    }

    public struct Themes: Decodable {
        public let light: NotificareOptions.Theme?
        public let dark: NotificareOptions.Theme?

        public init(light: NotificareOptions.Theme?, dark: NotificareOptions.Theme?) {
            self.light = light
            self.dark = dark
        }
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

        public init(backgroundColor: String?, actionButtonTextColor: String?, toolbarBackgroundColor: String?, activityIndicatorColor: String?, buttonTextColor: String?, textFieldTextColor: String?, textFieldBackgroundColor: String?, safariBarTintColor: String?, safariControlsTintColor: String?) {
            self.backgroundColor = backgroundColor
            self.actionButtonTextColor = actionButtonTextColor
            self.toolbarBackgroundColor = toolbarBackgroundColor
            self.activityIndicatorColor = activityIndicatorColor
            self.buttonTextColor = buttonTextColor
            self.textFieldTextColor = textFieldTextColor
            self.textFieldBackgroundColor = textFieldBackgroundColor
            self.safariBarTintColor = safariBarTintColor
            self.safariControlsTintColor = safariControlsTintColor
        }
    }
}

// Default options
public extension NotificareOptions {
    init() {
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
}

// Load options from a file
public extension NotificareOptions {
    init?(contentsOfFile plistPath: String) {
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
}

// Codable: NotificareOptions
public extension NotificareOptions {
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

    init(from decoder: Decoder) throws {
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
}

// Codable: NotificareOptions.Themes
public extension NotificareOptions.Themes {
    enum CodingKeys: String, CodingKey {
        case light = "LIGHT"
        case dark = "DARK"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        light = try container.decodeIfPresent(NotificareOptions.Theme.self, forKey: .light)
        dark = try container.decodeIfPresent(NotificareOptions.Theme.self, forKey: .dark)
    }
}

// Codable: NotificareOptions.Theme
public extension NotificareOptions.Theme {
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "BACKGROUND_COLOR"
        case actionButtonTextColor = "ACTION_BUTTON_TEXT_COLOR"
        case toolbarBackgroundColor = "TOOLBAR_BACKGROUND_COLOR"
        case activityIndicatorColor = "ACTIVITY_INDICATOR_COLOR"
        case buttonTextColor = "BUTTON_TEXT_COLOR"
        case textFieldTextColor = "TEXT_FIELD_TEXT_COLOR"
        case textFieldBackgroundColor = "TEXT_FIELD_BACKGROUND_COLOR"
        case safariBarTintColor = "SAFARI_BAR_TINT_COLOR"
        case safariControlsTintColor = "SAFARI_CONTROLS_TINT_COLOR"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
        actionButtonTextColor = try container.decodeIfPresent(String.self, forKey: .actionButtonTextColor)
        toolbarBackgroundColor = try container.decodeIfPresent(String.self, forKey: .toolbarBackgroundColor)
        activityIndicatorColor = try container.decodeIfPresent(String.self, forKey: .activityIndicatorColor)
        buttonTextColor = try container.decodeIfPresent(String.self, forKey: .buttonTextColor)
        textFieldTextColor = try container.decodeIfPresent(String.self, forKey: .textFieldTextColor)
        textFieldBackgroundColor = try container.decodeIfPresent(String.self, forKey: .textFieldBackgroundColor)
        safariBarTintColor = try container.decodeIfPresent(String.self, forKey: .safariBarTintColor)
        safariControlsTintColor = try container.decodeIfPresent(String.self, forKey: .safariControlsTintColor)
    }
}

// Load the appropriate theme for a given view controller
public extension NotificareOptions {
    func theme(for controller: UIViewController) -> NotificareOptions.Theme? {
        var theme = themes?.light

        if #available(iOS 13.0, *) {
            if controller.traitCollection.userInterfaceStyle == .dark, let darkTheme = self.themes?.dark {
                theme = darkTheme
            }
        }

        return theme
    }
}
