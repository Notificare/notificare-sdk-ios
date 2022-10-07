//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import UIKit

public struct NotificareOptions: Decodable {
    internal static let fileName = "NotificareOptions"
    internal static let fileExtension = "plist"

    public static let DEFAULT_DEBUG_LOGGING_ENABLED = false
    public static let DEFAULT_AUTO_CONFIG = true
    public static let DEFAULT_SWIZZLING_ENABLED = true
    public static let DEFAULT_USER_NOTIFICATION_CENTER_DELEGATE_ENABLED = true
    public static let DEFAULT_PRESERVE_EXISTING_NOTIFICATION_CATEGORIES = false
    public static let DEFAULT_CRASH_REPORTS_ENABLED = true
    public static let DEFAULT_HEADING_API_ENABLED = false
    public static let DEFAULT_VISITS_API_ENABLED = false
    public static let DEFAULT_IMAGE_SHARING_ENABLED = true
    public static let DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS = 5 * 60 * 1000

    public let debugLoggingEnabled: Bool
    public let autoConfig: Bool
    public let swizzlingEnabled: Bool
    public let userNotificationCenterDelegateEnabled: Bool
    public let preserveExistingNotificationCategories: Bool
    public let crashReportsEnabled: Bool
    public let headingApiEnabled: Bool
    public let visitsApiEnabled: Bool
    public let urlSchemes: [String]
    public let closeWindowQueryParameter: String?
    public let imageSharingEnabled: Bool
    public let safariDismissButtonStyle: Int?
    public let themes: Themes?
    public let backgroundGracePeriodMillis: Int

    public init(
        debugLoggingEnabled: Bool = DEFAULT_DEBUG_LOGGING_ENABLED,
        autoConfig: Bool = DEFAULT_AUTO_CONFIG,
        swizzlingEnabled: Bool = DEFAULT_SWIZZLING_ENABLED,
        userNotificationCenterDelegateEnabled: Bool = DEFAULT_USER_NOTIFICATION_CENTER_DELEGATE_ENABLED,
        preserveExistingNotificationCategories: Bool = DEFAULT_PRESERVE_EXISTING_NOTIFICATION_CATEGORIES,
        crashReportsEnabled: Bool = DEFAULT_CRASH_REPORTS_ENABLED,
        headingApiEnabled: Bool = DEFAULT_HEADING_API_ENABLED,
        visitsApiEnabled: Bool = DEFAULT_VISITS_API_ENABLED,
        urlSchemes: [String] = [],
        closeWindowQueryParameter: String? = nil,
        imageSharingEnabled: Bool = DEFAULT_IMAGE_SHARING_ENABLED,
        safariDismissButtonStyle: Int? = nil,
        themes: NotificareOptions.Themes? = nil,
        backgroundGracePeriodMillis: Int = DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS
    ) {
        self.debugLoggingEnabled = debugLoggingEnabled
        self.autoConfig = autoConfig
        self.swizzlingEnabled = swizzlingEnabled
        self.userNotificationCenterDelegateEnabled = userNotificationCenterDelegateEnabled
        self.preserveExistingNotificationCategories = preserveExistingNotificationCategories
        self.crashReportsEnabled = crashReportsEnabled
        self.headingApiEnabled = headingApiEnabled
        self.visitsApiEnabled = visitsApiEnabled
        self.urlSchemes = urlSchemes
        self.closeWindowQueryParameter = closeWindowQueryParameter
        self.imageSharingEnabled = imageSharingEnabled
        self.safariDismissButtonStyle = safariDismissButtonStyle
        self.themes = themes
        self.backgroundGracePeriodMillis = backgroundGracePeriodMillis
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
            preserveExistingNotificationCategories = decoded.preserveExistingNotificationCategories
            crashReportsEnabled = decoded.crashReportsEnabled
            headingApiEnabled = decoded.headingApiEnabled
            visitsApiEnabled = decoded.visitsApiEnabled
            urlSchemes = decoded.urlSchemes
            closeWindowQueryParameter = decoded.closeWindowQueryParameter
            imageSharingEnabled = decoded.imageSharingEnabled
            safariDismissButtonStyle = decoded.safariDismissButtonStyle
            themes = decoded.themes
            backgroundGracePeriodMillis = decoded.backgroundGracePeriodMillis
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
        case preserveExistingNotificationCategories = "PRESERVE_EXISTING_NOTIFICATION_CATEGORIES"
        case crashReportsEnabled = "CRASH_REPORTING_ENABLED"
        case headingApiEnabled = "HEADING_API_ENABLED"
        case visitsApiEnabled = "VISITS_API_ENABLED"
        case urlSchemes = "URL_SCHEMES"
        case closeWindowQueryParameter = "CLOSE_WINDOW_QUERY_PARAMETER"
        case imageSharingEnabled = "IMAGE_SHARING_ENABLED"
        case safariDismissButtonStyle = "SAFARI_DISMISS_BUTTON_STYLE"
        case themes = "THEMES"
        case backgroundGracePeriodMillis = "IAM_BACKGROUND_GRACE_PERIOD_MILLIS"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        debugLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugLoggingEnabled) ?? NotificareOptions.DEFAULT_DEBUG_LOGGING_ENABLED
        autoConfig = try container.decodeIfPresent(Bool.self, forKey: .autoConfig) ?? NotificareOptions.DEFAULT_AUTO_CONFIG
        swizzlingEnabled = try container.decodeIfPresent(Bool.self, forKey: .swizzlingEnabled) ?? NotificareOptions.DEFAULT_SWIZZLING_ENABLED
        userNotificationCenterDelegateEnabled = try container.decodeIfPresent(Bool.self, forKey: .userNotificationCenterDelegateEnabled) ?? NotificareOptions.DEFAULT_USER_NOTIFICATION_CENTER_DELEGATE_ENABLED
        preserveExistingNotificationCategories = try container.decodeIfPresent(Bool.self, forKey: .preserveExistingNotificationCategories) ?? NotificareOptions.DEFAULT_PRESERVE_EXISTING_NOTIFICATION_CATEGORIES
        crashReportsEnabled = try container.decodeIfPresent(Bool.self, forKey: .crashReportsEnabled) ?? NotificareOptions.DEFAULT_CRASH_REPORTS_ENABLED
        headingApiEnabled = try container.decodeIfPresent(Bool.self, forKey: .headingApiEnabled) ?? NotificareOptions.DEFAULT_HEADING_API_ENABLED
        visitsApiEnabled = try container.decodeIfPresent(Bool.self, forKey: .visitsApiEnabled) ?? NotificareOptions.DEFAULT_VISITS_API_ENABLED
        urlSchemes = try container.decodeIfPresent([String].self, forKey: .urlSchemes) ?? []
        closeWindowQueryParameter = try container.decodeIfPresent(String.self, forKey: .closeWindowQueryParameter)
        imageSharingEnabled = try container.decodeIfPresent(Bool.self, forKey: .imageSharingEnabled) ?? NotificareOptions.DEFAULT_IMAGE_SHARING_ENABLED
        safariDismissButtonStyle = try container.decodeIfPresent(Int.self, forKey: .safariDismissButtonStyle)
        themes = try container.decodeIfPresent(Themes.self, forKey: .themes)
        backgroundGracePeriodMillis = try container.decodeIfPresent(Int.self, forKey: .backgroundGracePeriodMillis) ?? NotificareOptions.DEFAULT_IAM_BACKGROUND_GRACE_PERIOD_MILLIS
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
